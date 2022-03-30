'use strict';

function initCombo(id,select_id) {
  var comboFilter = document.getElementById('combo-filter-' + id);
  var comboList = document.getElementById('combo-list-' + id);
  var comboDropdown = document.getElementById('combo-dropdown-' + id);
  comboFilter.addEventListener('focusin', showComboSelect);
  comboFilter.addEventListener('keyup', filterComboSelect);
  comboDropdown.addEventListener('click', toggleComboSelect);
  comboList.addEventListener("click", function(e) {
    var target_id = this.getAttribute("data-combo-id");
    var select_id = this.getAttribute("data-combo-for");
    e.preventDefault;
    document.getElementById('combo-filter-' + target_id).value = e.target.innerHTML;
    document.getElementById('combo-list-' + target_id).style.display = 'none';
    document.getElementById(select_id).value = e.target.getAttribute("data-key");
  });
}

function hideComboSelect() {
  var target_id = this.getAttribute("data-combo-id");
  document.getElementById('combo-list-' + target_id).style.display = 'none';
}

function showComboSelect() {
  var target_id = this.getAttribute("data-combo-id");
  document.getElementById('combo-list-' + target_id).style.display = 'block';
}

function toggleComboSelect() {
  var target_id = this.getAttribute("data-combo-id");
  if (document.getElementById('combo-list-' + target_id).style.display == 'block') {
    document.getElementById('combo-list-' + target_id).style.display = 'none';
  }
  else {
    document.getElementById('combo-list-' + target_id).style.display = 'block';
  }
}

function filterComboSelect() {
  var target_id = this.getAttribute("data-combo-id");
  var comboSelect = document.getElementById('combo-list-' + target_id);
  comboSelect.style.display = 'block';
  var filterText = this.value.toUpperCase();
  var allOptions = comboSelect.getElementsByTagName('li');
  for (let i = 0; i <= allOptions.length - 1; i++) {
     var li = allOptions[i];
     if (li.innerHTML.toUpperCase().indexOf(filterText) != -1) {
        li.style.display = 'block';
    } else {
        li.style.display = 'none';
    }
  }
}
