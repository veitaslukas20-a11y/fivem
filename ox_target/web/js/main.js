import { createOptions } from "./createOptions.js";

const optionsWrapper = document.getElementById("options-wrapper");
const body = document.body;
const eye = document.getElementById("eye");
const eyeIcon = document.getElementById("eyeIcon");

let isMenuOpen = false;
let allOptions = []; // Store all available options
let currentPage = 0;
const optionsPerPage = 5;

// Function to calculate position for radial menu
function getRadialPosition(index, total, radius = 120) {
  const angle = (index / total) * 2 * Math.PI - Math.PI / 2; // Start from top
  const x = Math.cos(angle) * radius;
  const y = Math.sin(angle) * radius;
  return { x, y };
}

// Function to create navigation buttons
function createNavigationButton(type, onClick) {
  const button = document.createElement("div");
  const isMore = type === "more";
  
  button.innerHTML = `
    <i class="fa-fw ${isMore ? 'fas fa-ellipsis-h' : 'fas fa-arrow-left'} option-icon"></i>
    <p class="option-label">${isMore ? 'Daugiau' : 'Grįžti'}</p>
  `;
  
  button.className = "option-container";
  button.addEventListener("click", onClick);
  
  return button;
}

// Function to get current page options
function getCurrentPageOptions() {
  const startIndex = currentPage * optionsPerPage;
  const endIndex = Math.min(startIndex + optionsPerPage, allOptions.length);
  return allOptions.slice(startIndex, endIndex);
}

// Function to check if we need pagination
function needsPagination() {
  return allOptions.length > optionsPerPage;
}

// Function to get total pages
function getTotalPages() {
  return Math.ceil(allOptions.length / optionsPerPage);
}

// Function to render current page
function renderCurrentPage() {
  // Clear existing options
  optionsWrapper.innerHTML = "";
  
  const pageOptions = getCurrentPageOptions();
  const hasNextPage = currentPage < getTotalPages() - 1;
  const hasPrevPage = currentPage > 0;
  
  // Add page options
  pageOptions.forEach((option) => {
    const optionElement = createOptionElement(option);
    optionsWrapper.appendChild(optionElement);
  });
  
  // Add navigation buttons if needed
  if (needsPagination()) {
    if (hasNextPage) {
      const moreButton = createNavigationButton("more", () => {
        currentPage++;
        closeMenu(false, true);
        setTimeout(() => {
          renderCurrentPage();
          openMenu();
        }, 100);
      });
      optionsWrapper.appendChild(moreButton);
    }
    
    if (hasPrevPage) {
      const backButton = createNavigationButton("back", () => {
        currentPage--;
        closeMenu(false, true);
        setTimeout(() => {
          renderCurrentPage();
          openMenu();
        }, 100);
      });
      optionsWrapper.appendChild(backButton);
    }
  }
}

// Function to create option element (extracted from createOptions.js logic)
function createOptionElement(optionData) {
  const { type, data, id, zoneId } = optionData;

  const option = document.createElement("div");
  const iconElement = `<i class="fa-fw ${data.icon} option-icon" ${
    data.iconColor ? `style="color:${data.iconColor} !important"` : ""
  }"></i>`;

  option.innerHTML = `${iconElement}<p class="option-label">${data.label}</p>`;
  option.className = "option-container";
  option.targetType = type;
  option.targetId = id;
  option.zoneId = zoneId;

  option.addEventListener("click", function onClick() {
    // when nuifocus is disabled after a click, the hover event is never released
    this.style.pointerEvents = "none";

    // Import fetchNui here or make it globally available
    import("./fetchNui.js").then(({ fetchNui }) => {
      fetchNui("select", [this.targetType, this.targetId, this.zoneId]);
    });
    
    // Close the menu after selection
    const event = new CustomEvent("closeMenu");
    window.dispatchEvent(event);

    setTimeout(() => (this.style.pointerEvents = "auto"), 100);
  });

  return option;
}

// Function to open the radial menu
function openMenu() {
  if (isMenuOpen) return;
  
  isMenuOpen = true;
  eyeIcon.className = "fas fa-times eye-icon"; // Change to close icon
  optionsWrapper.classList.add("options-visible");
  eye.classList.remove("eye-active");

  // Position and animate existing options
  const options = optionsWrapper.querySelectorAll(".option-container");
  options.forEach((option, index) => {
    const pos = getRadialPosition(index, options.length);
    option.style.left = `${pos.x}px`;
    option.style.top = `${pos.y}px`;
    option.style.transform = `translate(-50%, -50%)`;
    
    // Trigger animation
    setTimeout(() => {
      option.classList.add("show");
    }, 50 + index * 50);
  });
}

// Function to close the radial menu
function closeMenu(userClosed = false, immediate = false) {
  if (!isMenuOpen && !immediate) return;
  
  isMenuOpen = false;
  eyeIcon.className = "fas fa-eye eye-icon";

  if (immediate) {
    optionsWrapper.classList.remove("options-visible");
    optionsWrapper.innerHTML = "";
    return;
  }
  
  const options = optionsWrapper.querySelectorAll(".option-container");
  options.forEach((option, index) => {
    setTimeout(() => {
      option.classList.remove("show");
    }, index * 30);
  });

  setTimeout(() => {
    optionsWrapper.classList.remove("options-visible");
    if (!userClosed) {
      optionsWrapper.innerHTML = "";
      // Reset to first page when menu closes automatically
      currentPage = 0;
    }
  }, 400);
}

// Eye click handler
eye.addEventListener("click", () => {
  if (isMenuOpen) {
    closeMenu(true);
    currentPage = 0; // Reset to first page when manually closed
  } else {
    openMenu();
  }
});

window.addEventListener('closeMenu', () => { 
  closeMenu();
  currentPage = 0; // Reset to first page
});

// Message handler for integration with your existing system
window.addEventListener("message", (event) => {
  switch (event.data.event) {
    case "visible": {
      if (!event.data.state) {
        closeMenu(false, true);
        eye.style.transition = "none";
        body.style.visibility = "hidden";
        eye.classList.remove("eye-active");
        eye.style.display = 'none';
        currentPage = 0; // Reset pagination
      } else {
        body.style.visibility = "visible";
        eye.style.transition = "all 0.3s ease";
        eye.style.display = 'flex';
      }
      break;
    }

    case "leftTarget": {
      closeMenu();
      eye.classList.remove("eye-active");
      currentPage = 0; // Reset pagination
      break;
    }

    case "setTarget": {
      eye.classList.add("eye-active");
      allOptions = []; // Reset all options
      currentPage = 0; // Reset to first page
      
      if (isMenuOpen) {
        closeMenu();
      }

      // Collect all options into allOptions array
      if (event.data.options) {
        for (const type in event.data.options) {
          event.data.options[type].forEach((data, id) => {
            if (!data.hide) { // Only add options that are not hidden
              allOptions.push({ type, data, id: id + 1 });
            }
          });
        }
      }

      if (event.data.zones) {
        for (let i = 0; i < event.data.zones.length; i++) {
          event.data.zones[i].forEach((data, id) => {
            if (!data.hide) { // Only add options that are not hidden
              allOptions.push({ 
                type: "zones", 
                data, 
                id: id + 1, 
                zoneId: i + 1 
              });
            }
          });
        }
      }

      // Render the first page
      renderCurrentPage();
      break;
    }
  }
});