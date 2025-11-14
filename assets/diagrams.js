/**
 * Diagram Management for Final Year Project Report
 * This module handles all diagram imports and provides them to the main report
 */

// Diagram configuration array
const diagrams = [
  {
    id: 'ieee754-format',
    title: 'IEEE-754 Single-Precision Format',
    filename: 'ieee754_format.png',
    alt: 'IEEE-754 32-bit floating point format showing sign, exponent, and fraction fields',
    section: 3,
    description: 'Bit field breakdown of IEEE-754 single-precision format'
  },
  {
    id: 'proposed-architecture',
    title: 'Proposed Floating Point Multiplier Architecture',
    filename: 'proposed_architecture.png',
    alt: 'Block diagram of the proposed floating point multiplier architecture',
    section: 4,
    description: 'Overall system architecture with functional units'
  },
  {
    id: 'pipeline-architecture',
    title: 'Two-Stage Pipeline Architecture',
    filename: 'pipeline_architecture.png',
    alt: 'Pipeline architecture diagram showing Stage 1 and Stage 2',
    section: 5,
    description: 'Detailed pipeline stages with register banks'
  },
  {
    id: 'vedic-hierarchy',
    title: 'Vedic Multiplier Hierarchy',
    filename: 'vedic_hierarchy.png',
    alt: 'Hierarchical structure of Vedic multiplier from 3x3 to 24x24',
    section: 6,
    description: 'Recursive hierarchy: 3×3 → 6×6 → 12×12 → 24×24'
  },
  {
    id: 'rtl-schematic',
    title: 'RTL Schematic',
    filename: 'rtl_schematic.png',
    alt: 'Register Transfer Level schematic from Vivado synthesis',
    section: 8,
    description: 'Synthesized RTL schematic showing hardware implementation'
  },
  {
    id: 'waveform-normal',
    title: 'Simulation Waveform - Normal Operation',
    filename: 'waveform_normal.png',
    alt: 'Simulation waveform for normal multiplication (3.5 × -2.0)',
    section: 9,
    description: 'Testbench waveform showing normal operation'
  },
  {
    id: 'waveform-zero',
    title: 'Simulation Waveform - Zero Handling',
    filename: 'waveform_zero.png',
    alt: 'Simulation waveform for zero multiplication (0 × 5.0)',
    section: 9,
    description: 'Special case handling: zero input'
  },
  {
    id: 'waveform-nan',
    title: 'Simulation Waveform - NaN Handling',
    filename: 'waveform_nan.png',
    alt: 'Simulation waveform for NaN multiplication',
    section: 9,
    description: 'Special case handling: NaN propagation'
  }
];

/**
 * Get diagram path by ID
 * @param {string} id - Diagram identifier
 * @returns {string} - Full path to diagram image
 */
function getDiagramPath(id) {
  const diagram = diagrams.find(d => d.id === id);
  return diagram ? `assets/${diagram.filename}` : null;
}

/**
 * Get diagram by ID
 * @param {string} id - Diagram identifier
 * @returns {object|null} - Diagram configuration object
 */
function getDiagram(id) {
  return diagrams.find(d => d.id === id) || null;
}

/**
 * Get all diagrams for a specific section
 * @param {number} section - Section number
 * @returns {array} - Array of diagram objects
 */
function getDiagramsBySection(section) {
  return diagrams.filter(d => d.section === section);
}

/**
 * Create HTML img element for a diagram
 * @param {string} id - Diagram identifier
 * @returns {string} - HTML string for img element
 */
function createDiagramHTML(id) {
  const diagram = getDiagram(id);
  if (!diagram) return '';
  
  return `<img src="assets/${diagram.filename}" alt="${diagram.alt}" style="width:100%; max-width:800px; height:auto; display:block; margin:15px auto;" />`;
}

// Export for use in other modules
if (typeof module !== 'undefined' && module.exports) {
  module.exports = {
    diagrams,
    getDiagramPath,
    getDiagram,
    getDiagramsBySection,
    createDiagramHTML
  };
}

// Make available globally for HTML usage
window.DiagramManager = {
  diagrams,
  getDiagramPath,
  getDiagram,
  getDiagramsBySection,
  createDiagramHTML
};
