import { fetchNui } from "./fetchNui.js";

const optionsWrapper = document.getElementById("options-wrapper");

function onClick() {
  // when nuifocus is disabled after a click, the hover event is never released
  this.style.pointerEvents = "none";

  fetchNui("select", [this.targetType, this.targetId, this.zoneId]);
  
  // Close the menu after selection
  const event = new CustomEvent("closeMenu");
  window.dispatchEvent(event);
  

  setTimeout(() => (this.style.pointerEvents = "auto"), 100);
}

export function createOptions(type, data, id, zoneId) {
  if (data.hide) return;

  const option = document.createElement("div");
  const iconElement = `<i class="fa-fw ${data.icon} option-icon" ${
    data.iconColor ? `style="color:${data.iconColor} !important"` : ""
  }"></i>`;

  option.innerHTML = `${iconElement}<p class="option-label">${data.label}</p>`;
  option.className = "option-container";
  option.targetType = type;
  option.targetId = id;
  option.zoneId = zoneId;

  // Don't position the option here - it will be positioned when the menu opens
  option.addEventListener("click", onClick);
  optionsWrapper.appendChild(option);
}