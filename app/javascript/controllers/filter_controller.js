import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

  static targets = [ "source", "filterable" ]

  filter(event) {
    console.log("Filtering")
    let lowerCaseFilterTerm = this.sourceTarget.value.toLowerCase()

    this.filterableTargets.forEach((el, i) => {
      let filterableKey =  el.getAttribute("data-filter-key")

      el.classList.toggle("filter--notFound", !filterableKey.includes( lowerCaseFilterTerm ) )
    }
  }
}
