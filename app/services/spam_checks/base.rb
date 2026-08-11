# frozen_string_literal: true

module SpamChecks
  # Base defines the interface (via duck typing) that every spam check
  # implements. A check is a small object constructed with the request-derived
  # context it needs, exposing a single #call that returns a Result.
  #
  # Subclasses override:
  #   - #applicable?  (optional) — should this check run for this submission?
  #   - #evaluate        (required) — run the spam check, returning one of :reject :flag :surface :pass
  class Base
    # status is one of :pass, :reject, :flag, :surface, :not_applied
    #
    # context is an optional, JSON-serializable Hash of structured detail a
    # check may attach to explain its result (e.g. the invalid referer). It is
    # persisted alongside the reason so a human-readable description can be
    # reconstructed later; keys should be plain strings.
    Result = Data.define(:name, :status, :context) do
      def reject? = status == :reject
      def flag? = status == :flag
      def surface? = status == :surface
      def not_applied? = status == :not_applied
    end

    # Reduce an array of Results to a plain { name => status_string } hash,
    # suitable for a notification payload or JSONB persistence (no object
    # references, safe to serialize / enqueue).
    def self.results_to_h(results)
      results.each_with_object({}) do |result, hash|
        hash[result.name] = result.status.to_s
      end
    end

    # Human-readable label for this check, shown in the admin interface.
    # Defaults to a humanized version of the check name; subclasses set LABEL.
    def self.label
      const_defined?(:LABEL, false) ? const_get(:LABEL) : check_name.humanize
    end

    # Plain-language explanation of why this check flags a response.
    # Subclasses set DESCRIPTION; nil when unset. Accepts an optional context
    # Hash (as persisted in the Result) so subclasses can produce a dynamic,
    # detail-specific description; the default ignores it.
    def self.description(_context = {})
      const_get(:DESCRIPTION) if const_defined?(:DESCRIPTION, false)
    end

    # The check's persisted identifier, matching the #name written to
    # submission.spam_determination["reasons"] (e.g. "honeypot").
    def self.check_name
      const_get(:CHECK_NAME)
    end

    # Look up a subclass by its check name (e.g. "honeypot"). Returns nil for
    # unknown names.
    def self.for(check_name)
      checks.find { |klass| klass.check_name == check_name.to_s }
    end

    # The known spam check subclasses. Listed explicitly (rather than via
    # .subclasses) so lookups work regardless of autoloading/eager-load state.
    def self.checks
      [SpamChecks::Honeypot, SpamChecks::Referer, SpamChecks::Turnstile]
    end

    def initialize(submission:, context: {})
      @submission = submission
      @context = context
    end

    def call
      applicable? ? result(evaluate) : result(:not_applied)
    end

    private

    attr_reader :submission, :context

    def result(status)
      Result.new(name: name, status: status, context: result_context)
    end

    # Structured, JSON-serializable detail to persist with this check's result.
    # Defaults to an empty Hash; subclasses override to expose specifics (e.g.
    # the invalid referer) used to reconstruct a description later.
    def result_context
      {}
    end

    def name
      self.class.check_name
    end

    def applicable?
      true
    end

    def evaluate
      raise NotImplementedError, "#{self.class} must implement #evaluate"
    end
  end
end
