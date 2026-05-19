class NcertChapters {
  static const List<String> class11 = [
    'The Living World',
    'Biological Classification',
    'Plant Kingdom',
    'Animal Kingdom',
    'Morphology of Flowering Plants',
    'Anatomy of Flowering Plants',
    'Structural Organisation in Animals',
    'Cell: The Unit of Life',
    'Biomolecules',
    'Cell Cycle and Cell Division',
    'Transport in Plants',
    'Mineral Nutrition',
    'Photosynthesis in Higher Plants',
    'Respiration in Plants',
    'Plant Growth and Development',
    'Digestion and Absorption',
    'Breathing and Exchange of Gases',
    'Body Fluids and Circulation',
    'Excretory Products and their Elimination',
    'Locomotion and Movement',
    'Neural Control and Coordination',
    'Chemical Coordination and Integration',
  ];

  static const List<String> class12 = [
    'Reproduction in Organisms',
    'Sexual Reproduction in Flowering Plants',
    'Human Reproduction',
    'Reproductive Health',
    'Principles of Inheritance and Variation',
    'Molecular Basis of Inheritance',
    'Evolution',
    'Human Health and Disease',
    'Strategies for Enhancement in Food Production',
    'Microbes in Human Welfare',
    'Biotechnology: Principles and Processes',
    'Biotechnology and its Applications',
    'Organisms and Populations',
    'Ecosystem',
    'Biodiversity and Conservation',
    'Environmental Issues',
  ];

  static List<String> get allChapters => [...class11, ...class12];

  static String classFor(String chapter) {
    if (class11.contains(chapter)) return '11';
    if (class12.contains(chapter)) return '12';
    return 'Unknown';
  }

  static List<String> chaptersForClass(String cls) {
    if (cls == '11') return class11;
    if (cls == '12') return class12;
    return allChapters;
  }

  static int chapterNumber(String chapter) {
    final i11 = class11.indexOf(chapter);
    if (i11 != -1) return i11 + 1;
    final i12 = class12.indexOf(chapter);
    if (i12 != -1) return i12 + 1;
    return 0;
  }
}
