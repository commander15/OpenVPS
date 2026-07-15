/**
 * Generates dynamic FontAwesome classes and Tailwind color classes based on the icon configuration.
 * Includes a clean default configuration if an icon object is missing or invalid.
 * * @param {Object} icon - The structured icon configuration from JSON
 * @returns {string} Fully constructed <i> HTML element string
 */
function getIconHTML(icon) {
    const safeIcon = icon || {
        name: 'fa-gears',
        color: 'indigo',
        intensity: 400,
        brand: false
    };
    
    // Correcting FontAwesome brand library syntax ('fa-brands' instead of 'fa-brand')
    const libraryClass = safeIcon.brand ? 'fa-brands' : 'fa-solid';
    const colorClass = `text-${safeIcon.color}-${safeIcon.intensity || 400}`;
    
    return `
        <div class="flex justify-center items-center w-8 h-8">
            <i class="${libraryClass} ${safeIcon.name} text-3xl ${colorClass}"></i>
        </div>
    `;
}

/**
 * Builds the complete HTML string representation of a single tool's service card.
 * * @param {Object} tool - Individual tool object from the configuration
 * @returns {string} Complete Card HTML template
 */
function generateCardMarkup(tool) {
    const toolUrl = `http://${window.location.hostname}:${tool.admin_port}`;
    
    const iconHTML = getIconHTML(tool.icon);
    
    var public_ports = '';
    if ((tool.public_ports || []).length > 0) {
        public_ports = `<div class="bg-emerald-400 w-1 h-full rounded-sm mx-1"></div>`;
        public_ports += `<span class="text-sky-400 font-semibold">${tool.public_ports.join(', ')}</span>`;
    }

    return `
        <div class="bg-cardBg border border-slate-800 hover:border-indigo-500/50 rounded-xl p-6 transition-all duration-300 hover:-translate-y-1 hover:shadow-lg hover:shadow-indigo-500/5 flex flex-col justify-between group">
            <div>
                <div class="flex items-center justify-between mb-5">
                    <div class="p-2.5 bg-slate-900 rounded-lg group-hover:bg-indigo-950/40 transition-colors duration-300">
                        ${iconHTML}
                    </div>
                    <span class="flex h-2.5 w-2.5 relative">
                        <span class="animate-ping absolute inline-flex h-full w-full rounded-full bg-emerald-400 opacity-75"></span>
                        <span class="relative inline-flex rounded-full h-2.5 w-2.5 bg-emerald-500"></span>
                    </span>
                </div>
                
                <h3 class="text-lg font-bold text-white group-hover:text-indigo-400 transition-colors duration-300">
                    ${tool.name}
                </h3>
                
                <div class="mt-3 space-y-1.5 text-xs text-slate-400 font-mono">
                    <p class="flex justify-between border-b border-slate-800/50 pb-1">
                        <span class="text-slate-500">Host:</span> 
                        <span class="text-slate-300">${tool.host}</span>
                    </p>
                    <div class="flex justify-between">
                        <span class="text-slate-500">Ports:</span>
                        <div class="grow"></div>
                        <span class="text-indigo-400 font-semibold">${tool.admin_port}</span>
                        ${public_ports}
                    </div>
                </div>
            </div>

            <div class="mt-6">
                <a href="${toolUrl}" target="_blank" rel="noopener noreferrer" 
                   class="w-full inline-flex items-center justify-center gap-2 bg-slate-800 hover:bg-indigo-600 text-slate-200 hover:text-white py-2.5 px-4 rounded-lg font-medium text-sm transition-all duration-200">
                    Open Panel
                    <i class="fa-solid fa-arrow-up-right-from-square text-xs"></i>
                </a>
            </div>
        </div>
    `;
}

/**
 * Injects a warning box UI when the JSON panel config yields zero valid configurations.
 * * @param {HTMLElement} container - Target DOM node to mount the empty state
 */
function renderEmptyState(container) {
    container.innerHTML = `
        <div class="col-span-full text-center py-12 text-slate-400 bg-cardBg rounded-xl border border-slate-800">
            <i class="fa-solid fa-circle-exclamation text-3xl text-amber-500 mb-2"></i>
            <p class="font-semibold">No services configured.</p>
        </div>`;
}

/**
 * Main Controller orchestrator. Coordinates clearing state, validating tool 
 * payloads, compiling the list layouts, and executing the DOM paint.
 * * @param {Object} data - Parsed JSON object containing tool metadata
 */
function renderTools(data) {
    const container = document.getElementById('tools-container');
    if (!container) return;
    
    // Clear the active spinner status
    container.innerHTML = '';

    // Safeguard empty datasets early
    if (!data || !data.tools || data.tools.length === 0) {
        renderEmptyState(container);
        return;
    }

    // Assemble and paint all cards in one browser frame operation
    const cardsHTML = data.tools.map(tool => generateCardMarkup(tool)).join('');
    container.insertAdjacentHTML('beforeend', cardsHTML);
}

// Global initialization setup
document.addEventListener('DOMContentLoaded', () => {
    fetch('config.json')
        .then(response => {
            if (!response.ok) throw new Error(`HTTP status error: ${response.status}`);
            return response.json();
        })
        .then(data => renderTools(data))
        .catch(error => {
            console.error("Error loading panel configuration:", error);
            const container = document.getElementById('tools-container');
            if (container) {
                container.innerHTML = `
                    <p class="text-red-500 col-span-full text-center py-6">
                        Failed to load configuration panel. Verify your config.json matches the schema.
                    </p>`;
            }
        });
});
