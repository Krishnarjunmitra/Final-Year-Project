const figures = [
  {
    id: 'ieee754-format',
    figNum: 1,
    title: 'IEEE-754 Single-Precision Format',
    filename: 'ieee754_format.png',
    alt: 'IEEE-754 32-bit floating point format showing sign, exponent, and fraction fields',
    section: 3,
    description: 'Bit field breakdown of IEEE-754 single-precision format'
  },
  {
    id: 'proposed-architecture',
    figNum: 2,
    title: 'Proposed Floating Point Multiplier Architecture',
    filename: 'proposed_architecture.png',
    alt: 'Block diagram of the proposed floating point multiplier architecture',
    section: 4,
    description: 'Overall system architecture with functional units'
  },
  {
    id: 'pipeline-architecture',
    figNum: 3,
    title: 'Two-Stage Pipeline Architecture',
    filename: 'pipeline_architecture.png',
    alt: 'Pipeline architecture diagram showing Stage 1 and Stage 2',
    section: 5,
    description: 'Detailed pipeline stages with register banks'
  },
  {
    id: 'vedic-hierarchy',
    figNum: 4,
    title: 'Vedic Multiplier Hierarchy',
    filename: 'vedic_hierarchy.png',
    alt: 'Hierarchical structure of Vedic multiplier from 3x3 to 24x24',
    section: 6,
    description: 'Recursive hierarchy: 3×3 → 6×6 → 12×12 → 24×24'
  },
  {
    id: 'rtl-schematic',
    figNum: 5,
    title: 'RTL Schematic',
    filename: 'rtl_schematic.png',
    alt: 'Register Transfer Level schematic from Vivado synthesis',
    section: 8,
    description: 'Synthesized RTL schematic showing hardware implementation'
  },
  {
    id: 'waveform-normal',
    figNum: 6,
    title: 'Simulation Waveform - Normal Operation',
    filename: 'waveform_normal.png',
    alt: 'Simulation waveform for normal multiplication (3.5 × -2.0)',
    section: 9,
    description: 'Testbench waveform showing normal operation'
  },
  {
    id: 'waveform-zero',
    figNum: 7,
    title: 'Simulation Waveform - Zero Handling',
    filename: 'waveform_zero.png',
    alt: 'Simulation waveform for zero multiplication (0 × 5.0)',
    section: 9,
    description: 'Special case handling: zero input'
  },
  {
    id: 'waveform-nan',
    figNum: 8,
    title: 'Simulation Waveform - NaN Handling',
    filename: 'waveform_nan.png',
    alt: 'Simulation waveform for NaN multiplication',
    section: 9,
    description: 'Special case handling: NaN propagation'
  }
];

/**
 * Get figure path by ID
 * @param {string} id - Figure identifier
 * @returns {string} - Full path to figure image
 */
function getFigurePath(id) {
  const figure = figures.find(f => f.id === id);
  return figure ? `assets/${figure.filename}` : null;
}

/**
 * Get figure by ID
 * @param {string} id - Figure identifier
 * @returns {object|null} - Figure configuration object
 */
function getFigure(id) {
  return figures.find(f => f.id === id) || null;
}

/**
 * Get all figures for a specific section
 * @param {number} section - Section number
 * @returns {array} - Array of figure objects
 */
function getFiguresBySection(section) {
  return figures.filter(f => f.section === section);
}

/**
 * Create HTML figure element with caption
 * @param {string} id - Figure identifier
 * @returns {string} - HTML string for figure element with figcaption
 */
function createFigureHTML(id) {
  const figure = getFigure(id);
  if (!figure) return '';
  
  return `<figure class="diagram" id="diagram-${figure.id}">
    <img src="assets/${figure.filename}" alt="${figure.alt}" 
         onerror="this.parentElement.innerHTML='<div class=\'placeholder\'>[Figure ${figure.figNum}: ${figure.title} - Image: assets/${figure.filename}]</div>'">
    <figcaption><strong>Fig. ${figure.figNum}:</strong> ${figure.title}</figcaption>
  </figure>`;
}

// Export for use in other modules
if (typeof module !== 'undefined' && module.exports) {
  module.exports = {
    figures,
    getFigurePath,
    getFigure,
    getFiguresBySection,
    createFigureHTML
  };
}

// Make available globally for HTML usage
window.FigureManager = {
  figures,
  getFigurePath,
  getFigure,
  getFiguresBySection,
  createFigureHTML
};
