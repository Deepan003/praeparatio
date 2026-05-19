/// Second batch of NCERT Biology game content.
/// All content verified against NCERT Class 11 & 12 Biology textbooks.
library game_data_2;

// ── NEET Rapid Fire — Direct factoid questions ─────────────────
class RapidFireQ {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String chapter;
  final String explanation;
  const RapidFireQ({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.chapter,
    required this.explanation,
  });
}

const List<RapidFireQ> rapidFireQuestions = [
  RapidFireQ(
    question: 'The oxygen-evolving complex (OEC) is associated with which photosystem?',
    options: ['PSI', 'PSII', 'Cytochrome b6f', 'ATP Synthase'],
    correctIndex: 1,
    chapter: 'Photosynthesis Ch 13',
    explanation: 'PSII (P680) splits water in the light reactions. 2H₂O → 4H⁺ + 4e⁻ + O₂. The OEC contains a Mn cluster.',
  ),
  RapidFireQ(
    question: 'Which bond holds complementary base pairs in DNA?',
    options: ['Covalent bond', 'Ionic bond', 'Hydrogen bond', 'Peptide bond'],
    correctIndex: 2,
    chapter: 'Molecular Basis Ch 6 (Class 12)',
    explanation: 'A–T: 2 H-bonds; G–C: 3 H-bonds. These weak but numerous bonds stabilise the double helix.',
  ),
  RapidFireQ(
    question: 'The net ATP yield from one molecule of glucose under complete aerobic oxidation is:',
    options: ['36–38 ATP', '2 ATP', '4 ATP', '30 ATP'],
    correctIndex: 0,
    chapter: 'Respiration Ch 14',
    explanation: 'Glycolysis (2) + Pyruvate decarboxylation (2) + Krebs (2) + Oxidative phosphorylation (32-34) = 36-38 ATP total.',
  ),
  RapidFireQ(
    question: 'Which enzyme is responsible for the transcription of DNA into RNA?',
    options: ['DNA Polymerase', 'RNA Polymerase', 'Reverse Transcriptase', 'Primase'],
    correctIndex: 1,
    chapter: 'Molecular Basis Ch 6 (Class 12)',
    explanation: 'RNA Polymerase reads the template strand 3\'→5\' and synthesises RNA 5\'→3\'. Sigma factor provides promoter recognition in prokaryotes.',
  ),
  RapidFireQ(
    question: 'Guttation in plants is the loss of water in the form of:',
    options: ['Water vapour through stomata', 'Liquid water through hydathodes', 'CO₂ through lenticels', 'Liquid water through stomata'],
    correctIndex: 1,
    chapter: 'Transport in Plants Ch 11',
    explanation: 'Guttation occurs at leaf margins through specialised pores called hydathodes when root pressure exceeds transpiration pull (usually at night).',
  ),
  RapidFireQ(
    question: 'The Bowman\'s glands (olfactory glands) are found in the:',
    options: ['Ear', 'Nose', 'Tongue', 'Eye'],
    correctIndex: 1,
    chapter: 'Neural Control Ch 21',
    explanation: 'Bowman\'s glands secrete mucus that dissolves odorant molecules in the olfactory epithelium of the nasal cavity.',
  ),
  RapidFireQ(
    question: 'Which of the following is a STOP codon?',
    options: ['AUG', 'UAA', 'GCU', 'UGG'],
    correctIndex: 1,
    chapter: 'Molecular Basis Ch 6 (Class 12)',
    explanation: 'The three stop (nonsense) codons are UAA ("ochre"), UAG ("amber"), and UGA ("opal/umber"). They do not code for amino acids.',
  ),
  RapidFireQ(
    question: 'The term "Ecology" was coined by:',
    options: ['Darwin', 'Ernst Haeckel', 'Odum', 'Tansley'],
    correctIndex: 1,
    chapter: 'Organism & Environment Ch 13 (Class 12)',
    explanation: 'Ernst Haeckel coined "Oekologie" in 1866. Odum wrote the first modern ecology textbook. Tansley coined "ecosystem."',
  ),
  RapidFireQ(
    question: 'Which gas is fixed by nitrogenase enzyme?',
    options: ['CO₂', 'O₂', 'N₂', 'H₂S'],
    correctIndex: 2,
    chapter: 'Mineral Nutrition Ch 12',
    explanation: 'Nitrogenase converts N₂ → 2NH₃ using 16 ATP. The enzyme is irreversibly inactivated by O₂, which is why Rhizobium needs leghaemoglobin in nodules.',
  ),
  RapidFireQ(
    question: 'Corpus luteum is formed from:',
    options: ['Ruptured Graafian follicle', 'Primordial follicle', 'Zona pellucida', 'Interstitial cells'],
    correctIndex: 0,
    chapter: 'Human Reproduction Ch 3 (Class 12)',
    explanation: 'After ovulation, the ruptured Graafian follicle becomes the corpus luteum, which secretes progesterone to maintain the endometrium.',
  ),
  RapidFireQ(
    question: 'Which layer of the meninges is the toughest?',
    options: ['Pia mater', 'Arachnoid mater', 'Dura mater', 'Subdural space'],
    correctIndex: 2,
    chapter: 'Neural Control Ch 21',
    explanation: 'Dura mater (Latin: tough mother) is the outermost and thickest meningeal layer. Pia mater is the innermost; arachnoid is middle.',
  ),
  RapidFireQ(
    question: 'C₄ plants perform the initial CO₂ fixation in:',
    options: ['Bundle sheath cells', 'Mesophyll cells', 'Guard cells', 'Epidermal cells'],
    correctIndex: 1,
    chapter: 'Photosynthesis Ch 13',
    explanation: 'In C₄ plants (Hatch-Slack pathway): CO₂ fixed in mesophyll cells by PEP carboxylase → OAA (4C) → transferred to bundle sheath → Calvin cycle runs there.',
  ),
  RapidFireQ(
    question: 'The universal recipient blood group in ABO system is:',
    options: ['A', 'B', 'O', 'AB'],
    correctIndex: 3,
    chapter: 'Human Health Ch 8 (Class 12)',
    explanation: 'AB blood group has no anti-A or anti-B antibodies, so it can receive blood from any ABO group (universal recipient). O is universal donor.',
  ),
  RapidFireQ(
    question: 'How many chromosomes does a normal human somatic cell have?',
    options: ['23', '44', '46', '48'],
    correctIndex: 2,
    chapter: 'Human Reproduction Ch 3 (Class 12)',
    explanation: '46 chromosomes = 23 pairs (22 autosomes + 1 sex chromosome pair). Gametes have 23 (haploid). Down syndrome = 47 (trisomy 21).',
  ),
  RapidFireQ(
    question: 'Biosphere II was a project designed to study:',
    options: ['Moon colonisation', 'Closed ecological systems', 'Ocean depth ecosystems', 'Polar ice ecology'],
    correctIndex: 1,
    chapter: 'Ecosystem Ch 14 (Class 12)',
    explanation: 'Biosphere II (Arizona, 1991) was a sealed 1.2 ha structure with 8 ecosystems. It studied whether humans could create a self-sufficient biosphere.',
  ),
  RapidFireQ(
    question: 'Which of the following is NOT a function of the liver?',
    options: ['Synthesis of bile', 'Glycogen storage', 'Insulin secretion', 'Detoxification'],
    correctIndex: 2,
    chapter: 'Digestion Ch 16',
    explanation: 'Insulin is secreted by the beta cells of the pancreas (islets of Langerhans), NOT the liver. The liver stores glycogen and secretes bile.',
  ),
  RapidFireQ(
    question: 'In plants, sieve tube members lack:',
    options: ['Cell wall', 'Nucleus', 'Plasma membrane', 'Cytoplasm'],
    correctIndex: 1,
    chapter: 'Anatomy of Plants Ch 6',
    explanation: 'Mature sieve tube members lack a nucleus (degenerated) and most organelles to maximise space for phloem transport. They are controlled by companion cells.',
  ),
  RapidFireQ(
    question: 'Fibrinogen is converted to Fibrin by the enzyme:',
    options: ['Thrombin', 'Plasmin', 'Heparin', 'Prothrombin'],
    correctIndex: 0,
    chapter: 'Circulation Ch 18',
    explanation: 'Thrombin (activated from prothrombin) converts soluble fibrinogen → insoluble fibrin threads that form the clot. Heparin prevents clotting.',
  ),
  RapidFireQ(
    question: 'Which plant hormone promotes fruit ripening?',
    options: ['Auxin', 'Gibberellin', 'Cytokinin', 'Ethylene'],
    correctIndex: 3,
    chapter: 'Plant Growth Ch 15',
    explanation: 'Ethylene (C₂H₄) is a gaseous hormone that promotes fruit ripening, leaf abscission, and senescence. It triggers climacteric respiration in fruits.',
  ),
  RapidFireQ(
    question: 'The concept of "Survival of the Fittest" was coined by:',
    options: ['Charles Darwin', 'Alfred Russel Wallace', 'Herbert Spencer', 'Jean Baptiste Lamarck'],
    correctIndex: 2,
    chapter: 'Evolution Ch 7 (Class 12)',
    explanation: 'Herbert Spencer coined "Survival of the Fittest" in 1864 after reading Darwin. Darwin used "natural selection." Wallace co-discovered evolution independently.',
  ),
];

// ── Assertion & Reason Questions ──────────────────────────────
class ARQuestion {
  final String assertion;
  final String reason;
  final int correct; // 0=A, 1=B, 2=C, 3=D
  // A=Both true, R explains A | B=Both true, R doesn't explain | C=A true R false | D=A false
  final String chapter;
  final String explanation;
  const ARQuestion({
    required this.assertion,
    required this.reason,
    required this.correct,
    required this.chapter,
    required this.explanation,
  });
}

const List<ARQuestion> arQuestions = [
  ARQuestion(
    assertion: 'The endosperm in angiosperms is triploid (3n).',
    reason: 'It is formed by the fusion of two polar nuclei (2n) with one male gamete (n).',
    correct: 0,
    chapter: 'Reproduction Ch 2 (Class 12)',
    explanation: 'Both are true. The endosperm IS triploid (3n = 2n + n). The reason correctly explains it — this is double fertilisation, unique to angiosperms.',
  ),
  ARQuestion(
    assertion: 'Earthworms are called the "farmers\' friends."',
    reason: 'Earthworms fix atmospheric nitrogen and make soil fertile.',
    correct: 1,
    chapter: 'Animal Kingdom Ch 4',
    explanation: 'The assertion is true — earthworms aerate soil and enrich it. BUT the reason is false — earthworms do NOT fix nitrogen. They enhance soil by mixing organic matter.',
  ),
  ARQuestion(
    assertion: 'Guard cells become turgid to open stomata.',
    reason: 'K⁺ ions accumulate in guard cells in the presence of light, increasing osmotic pressure.',
    correct: 0,
    chapter: 'Transport in Plants Ch 11',
    explanation: 'Both are true. Light triggers K⁺ influx into guard cells → water follows by osmosis → turgor increases → guard cells bow outward → stomata open.',
  ),
  ARQuestion(
    assertion: 'RNA acts as the genetic material in HIV.',
    reason: 'Retroviruses use reverse transcriptase to convert RNA → DNA → integrated into host genome.',
    correct: 0,
    chapter: 'Molecular Basis Ch 6 (Class 12)',
    explanation: 'Both true. HIV is a retrovirus with RNA genome. Reverse transcriptase converts it to DNA (provirus), which integrates into host DNA.',
  ),
  ARQuestion(
    assertion: 'All enzymes are proteins, but not all proteins are enzymes.',
    reason: 'Ribozymes are RNA molecules that have catalytic activity.',
    correct: 1,
    chapter: 'Biomolecules Ch 9',
    explanation: 'The assertion is TRUE. The reason is TRUE. BUT — the reason does not explain the assertion (it actually contradicts the first part). Ribozymes show not all enzymes are proteins.',
  ),
  ARQuestion(
    assertion: 'Vaccination provides active immunity.',
    reason: 'Vaccines introduce dead or attenuated pathogens that stimulate the immune system to produce memory cells.',
    correct: 0,
    chapter: 'Human Health Ch 8 (Class 12)',
    explanation: 'Both true. Active immunity = body produces its own antibodies. Vaccination triggers this by exposing the immune system to non-dangerous antigens.',
  ),
  ARQuestion(
    assertion: 'The cardiac output increases during exercise.',
    reason: 'During exercise, stroke volume and heart rate both increase under sympathetic stimulation.',
    correct: 0,
    chapter: 'Circulation Ch 18',
    explanation: 'Both true. Cardiac output = Stroke Volume × Heart Rate. Both increase during exercise under adrenaline/sympathetic stimulation.',
  ),
  ARQuestion(
    assertion: 'Oxygen is not produced during cyclic photophosphorylation.',
    reason: 'In cyclic photophosphorylation, only PSI is involved and water is not split.',
    correct: 0,
    chapter: 'Photosynthesis Ch 13',
    explanation: 'Both true. Cyclic photophosphorylation involves only PSI, electron returns to PSI, no water splitting, no NADPH, no O₂ — only ATP is produced.',
  ),
  ARQuestion(
    assertion: 'Genes on the same chromosome do not assort independently.',
    reason: 'Linked genes tend to remain together during meiosis and are inherited together.',
    correct: 0,
    chapter: 'Principles of Inheritance Ch 5 (Class 12)',
    explanation: 'Both true. Linked genes violate Mendel\'s Law of Independent Assortment. Morgan\'s drosophila experiments showed linkage and crossing over.',
  ),
  ARQuestion(
    assertion: 'In bryophytes, the gametophyte is the dominant generation.',
    reason: 'Bryophytes are the most primitive land plants and completely depend on water for fertilisation.',
    correct: 1,
    chapter: 'Plant Kingdom Ch 3',
    explanation: 'Assertion is TRUE. Reason is TRUE but does NOT explain why gametophyte is dominant. The reason describes their reproductive dependence on water, not the dominance.',
  ),
];

// ── Exception Hunter ──────────────────────────────────────────
class ExceptionItem {
  final String rule;
  final List<String> options;
  final List<int> exceptionIndices; // which options are exceptions
  final String explanation;
  final String chapter;
  const ExceptionItem({
    required this.rule,
    required this.options,
    required this.exceptionIndices,
    required this.explanation,
    required this.chapter,
  });
}

const List<ExceptionItem> exceptionItems = [
  ExceptionItem(
    rule: 'All mammals are viviparous (give birth to live young)',
    options: ['Blue Whale', 'Platypus', 'Tiger', 'Dolphin'],
    exceptionIndices: [1],
    explanation: 'Platypus (Ornithorhynchus) is an oviparous mammal — it lays eggs! Echidnas are the other exception. Both are monotremes.',
    chapter: 'Animal Kingdom Ch 4',
  ),
  ExceptionItem(
    rule: 'All legumes have Rhizobium in their root nodules',
    options: ['Gram (Cicer)', 'Pea', 'Cycas (a gymnosperm)', 'Soybean'],
    exceptionIndices: [2],
    explanation: 'Cycas is NOT a legume — it\'s a gymnosperm. Cycas has root nodules with Nostoc (a cyanobacterium), not Rhizobium!',
    chapter: 'Mineral Nutrition Ch 12',
  ),
  ExceptionItem(
    rule: 'Monocot stems have scattered vascular bundles',
    options: ['Maize', 'Sugarcane', 'Rice', 'Sunflower'],
    exceptionIndices: [3],
    explanation: 'Sunflower is a dicot! Dicot stems have vascular bundles arranged in a ring. Maize, sugarcane, and rice are monocots with scattered bundles.',
    chapter: 'Anatomy of Plants Ch 6',
  ),
  ExceptionItem(
    rule: 'All viruses are obligate intracellular parasites',
    options: ['Bacteriophage', 'HIV', 'TMV (Tobacco Mosaic Virus)', 'None — all viruses are intracellular'],
    exceptionIndices: [3],
    explanation: 'This rule has NO exceptions — ALL viruses are obligate intracellular parasites. They cannot replicate outside a host cell.',
    chapter: 'The Living World Ch 1',
  ),
  ExceptionItem(
    rule: 'Flowering plants (angiosperms) always have bisexual flowers',
    options: ['Papaya', 'Maize', 'Date Palm', 'Castor'],
    exceptionIndices: [0, 1, 2],
    explanation: 'Papaya, Maize, and Date Palm are UNISEXUAL (dioecious or monoecious). Not all angiosperms are bisexual. Castor is monoecious but has separate male/female flowers.',
    chapter: 'Sexual Reproduction Ch 2 (Class 12)',
  ),
  ExceptionItem(
    rule: 'Prokaryotes lack membrane-bound organelles',
    options: ['Ribosomes (70S)', 'Mitochondria', 'Mesosome', 'Endoplasmic Reticulum'],
    exceptionIndices: [0, 2],
    explanation: 'Prokaryotes DO have ribosomes (70S, non-membrane bound) and mesosomes (infoldings of plasma membrane). They lack true mitochondria and ER.',
    chapter: 'Cell Ch 8',
  ),
  ExceptionItem(
    rule: 'All snake species are venomous',
    options: ['Cobra (Naja)', 'Krait (Bungarus)', 'Python', 'Russell\'s Viper'],
    exceptionIndices: [2],
    explanation: 'Python is non-venomous — it kills prey by constriction. Only about 15% of the world\'s ~3,500 snake species are venomous.',
    chapter: 'Animal Kingdom Ch 4',
  ),
  ExceptionItem(
    rule: 'Fishes are cold-blooded (ectothermic)',
    options: ['Scomber (Mackerel)', 'Torpedo (Electric Ray)', 'Exocoetus (Flying Fish)', 'All fish are ectothermic'],
    exceptionIndices: [3],
    explanation: 'Nearly all fish are ectothermic. However, some large pelagic fish like tuna and great white sharks are partially endothermic (regional endothermy). NCERT treats all fish as ectothermic.',
    chapter: 'Animal Kingdom Ch 4',
  ),
];

// ── Biological Compound Wall (Connections) ────────────────────
class ConnectionsGroup {
  final String theme;
  final List<String> members; // exactly 4 members
  final String explanation;
  const ConnectionsGroup({
    required this.theme,
    required this.members,
    required this.explanation,
  });
}

class ConnectionsPuzzle {
  final String title;
  final List<ConnectionsGroup> groups; // exactly 4 groups of 4
  final String chapter;
  const ConnectionsPuzzle({
    required this.title,
    required this.groups,
    required this.chapter,
  });
}

const List<ConnectionsPuzzle> connectionsPuzzles = [
  ConnectionsPuzzle(
    title: 'Hormones by Chemical Nature',
    chapter: 'Chemical Coordination Ch 22',
    groups: [
      ConnectionsGroup(theme: '🟡 Peptide Hormones', members: ['Insulin', 'Glucagon', 'ADH', 'Oxytocin'],
          explanation: 'Peptide hormones are made of amino acids. They cannot cross plasma membranes and act via second messengers.'),
      ConnectionsGroup(theme: '🔴 Steroid Hormones', members: ['Cortisol', 'Testosterone', 'Estrogen', 'Progesterone'],
          explanation: 'Steroid hormones are derived from cholesterol. They are lipid-soluble and can cross membranes to bind nuclear receptors.'),
      ConnectionsGroup(theme: '🟢 Amine Hormones', members: ['Epinephrine', 'Thyroxine', 'Melatonin', 'Dopamine'],
          explanation: 'Amine hormones are derived from tyrosine or tryptophan. Include catecholamines (epinephrine, dopamine) and iodothyronines (thyroxine).'),
      ConnectionsGroup(theme: '🔵 Anterior Pituitary', members: ['GH', 'TSH', 'ACTH', 'Prolactin'],
          explanation: 'Anterior pituitary (adenohypophysis) secretes: GH, TSH (thyroid-stimulating), ACTH (adrenocorticotropic), FSH, LH, and Prolactin.'),
    ],
  ),
  ConnectionsPuzzle(
    title: 'Animals by Excretory Product',
    chapter: 'Excretory Products Ch 19',
    groups: [
      ConnectionsGroup(theme: '🟡 Ammonotelic (NH₃)', members: ['Bony fish', 'Aquatic amphibians', 'Prawns', 'Most invertebrates'],
          explanation: 'Ammonotelic animals excrete ammonia directly. Requires large amounts of water to dilute toxic NH₃. Only possible in aquatic environments.'),
      ConnectionsGroup(theme: '🔴 Ureotelic (Urea)', members: ['Mammals', 'Cartilaginous fish', 'Adult frogs', 'Aquatic turtles'],
          explanation: 'Ureotelic animals convert ammonia to urea in the liver (ornithine cycle). Less toxic, requires moderate water.'),
      ConnectionsGroup(theme: '🟢 Uricotelic (Uric Acid)', members: ['Birds', 'Reptiles', 'Insects', 'Land snails'],
          explanation: 'Uricotelic animals excrete uric acid — insoluble, semisolid waste. Perfect for water conservation in eggs and dry environments.'),
      ConnectionsGroup(theme: '🔵 Organs of Excretion', members: ['Flame cells (Platyhelminthes)', 'Nephridia (Annelids)', 'Malpighian tubules (Insects)', 'Green glands (Crustacea)'],
          explanation: 'Different animal groups evolved different excretory organs. Flame cells are the most primitive; vertebrate kidneys are the most advanced.'),
    ],
  ),
  ConnectionsPuzzle(
    title: 'Cells of the Immune System',
    chapter: 'Human Health Ch 8 (Class 12)',
    groups: [
      ConnectionsGroup(theme: '🟡 B-lymphocyte products', members: ['IgG', 'IgM', 'IgE', 'IgA'],
          explanation: 'B cells differentiate into plasma cells that secrete antibody immunoglobulins (Ig). IgG crosses placenta; IgM is first response; IgE triggers allergies.'),
      ConnectionsGroup(theme: '🔴 T-lymphocyte types', members: ['T-helper', 'T-killer (Cytotoxic)', 'T-suppressor', 'T-memory'],
          explanation: 'T cells mature in thymus. Helper T-cells coordinate the immune response. Cytotoxic T-cells kill infected cells. Suppressor T-cells prevent autoimmunity.'),
      ConnectionsGroup(theme: '🟢 Innate Immunity Cells', members: ['Neutrophils', 'Macrophages', 'NK cells', 'Dendritic cells'],
          explanation: 'Innate immunity is non-specific and immediate. Neutrophils (first responders), macrophages (phagocytes), NK cells (kill tumours/viruses), dendritic cells (antigen-presenting).'),
      ConnectionsGroup(theme: '🔵 Chemicals in Immunity', members: ['Interferon', 'Interleukin', 'Histamine', 'Complement proteins'],
          explanation: 'Chemical mediators: Interferons are antiviral proteins. Interleukins are cytokines for cell communication. Histamine triggers inflammation. Complement lyses pathogens.'),
    ],
  ),
];

// ── Journey Through the Nephron ───────────────────────────────
class NephronNode {
  final String location;
  final String description;
  final List<String> choices;
  final List<int> validMolecules; // indices into _nephronMolecules
  final int correctChoice; // which choice index is correct
  final String explanation;
  const NephronNode({
    required this.location,
    required this.description,
    required this.choices,
    required this.validMolecules,
    required this.correctChoice,
    required this.explanation,
  });
}

const List<String> nephronMolecules = [
  '💧 Water', '🍬 Glucose', '🧬 Urea', '🔴 RBC (Red Blood Cell)',
  '🔷 Plasma Protein (Albumin, 69kDa)', '⚡ Na⁺ ions', '🟡 Creatinine',
];

const List<NephronNode> nephronJourney = [
  NephronNode(
    location: 'Glomerulus',
    description: 'You\'ve entered the glomerulus — a tuft of capillaries with enormous hydrostatic pressure (60 mmHg). The filtration membrane has pores 18nm wide. Where do you go?',
    choices: ['Enter Bowman\'s capsule through filtration (FILTRATION)', 'Remain in the blood and exit via efferent arteriole'],
    validMolecules: [0, 1, 2, 5, 6], // Water, Glucose, Urea, Na+, Creatinine pass
    correctChoice: 0,
    explanation: 'Small molecules (water, glucose, ions, urea, creatinine) are filtered. Large proteins and RBCs CANNOT pass — they stay in blood. Plasma proteins >69kDa are too large for filtration slits.',
  ),
  NephronNode(
    location: 'Proximal Convoluted Tubule (PCT)',
    description: 'You\'ve made it into the filtrate! You\'re in the PCT — heavily coiled, with microvilli for maximum reabsorption. Most useful substances are reclaimed here.',
    choices: ['Get reabsorbed back into peritubular capillaries', 'Continue flowing into the loop of Henle'],
    validMolecules: [0, 1, 5], // Water, Glucose, Na+ reabsorbed
    correctChoice: 0,
    explanation: 'PCT reabsorbs: 70% of water, ALL glucose (by active transport + cotransport), amino acids, vitamins, and ions. Urea and creatinine are NOT reabsorbed here.',
  ),
  NephronNode(
    location: 'Loop of Henle (Descending limb)',
    description: 'You\'re descending into the medulla — becoming hypertonic. The descending limb is permeable to water but NOT ions. The medulla is increasingly salty around you.',
    choices: ['Exit the tubule by osmosis into the interstitium', 'Remain inside and continue to the ascending limb'],
    validMolecules: [0], // Only water exits descending
    correctChoice: 0,
    explanation: 'The descending limb is freely permeable to water but impermeable to Na⁺. Water leaves by osmosis into the hyperosmotic medulla. This concentrates the filtrate.',
  ),
  NephronNode(
    location: 'Loop of Henle (Ascending limb)',
    description: 'You\'re in the ascending limb, now heading back up toward the cortex. This segment is impermeable to water but actively pumps out ions.',
    choices: ['Exit via active transport of Na⁺ and Cl⁻', 'Follow water out of the tubule'],
    validMolecules: [5], // Only Na+ exits ascending
    correctChoice: 0,
    explanation: 'The ascending limb actively transports Na⁺ and Cl⁻ out (diluting the filtrate) but is impermeable to water. This creates the medullary hyperosmolarity that drives urine concentration.',
  ),
  NephronNode(
    location: 'Collecting Duct — ADH present',
    description: 'You\'re in the collecting duct. ADH (vasopressin) has been detected in the bloodstream — the body is dehydrated. The collecting duct is now PERMEABLE to water.',
    choices: ['Exit the duct into the concentrated medulla (concentrated urine)', 'Remain in the duct and be excreted as dilute urine'],
    validMolecules: [0, 2], // Water gets reabsorbed, Urea concentrates
    correctChoice: 0,
    explanation: 'ADH inserts aquaporin channels into the collecting duct → water reabsorbed by osmosis → concentrated urine (hyperosmotic). Without ADH → dilute urine (diabetes insipidus).',
  ),
];

// ── DNA Replication Fork Tasks ────────────────────────────────
class ReplicationTask {
  final String task;
  final String correctEnzyme;
  final List<String> options;
  final String chapter;
  final String explanation;
  const ReplicationTask({
    required this.task,
    required this.correctEnzyme,
    required this.options,
    required this.chapter,
    required this.explanation,
  });
}

const List<ReplicationTask> replicationTasks = [
  ReplicationTask(
    task: 'STEP 1: Unwind the double helix at the replication fork by breaking hydrogen bonds.',
    correctEnzyme: 'Helicase',
    options: ['Helicase', 'Ligase', 'DNA Pol III', 'SSB proteins'],
    chapter: 'Molecular Basis Ch 6 (Class 12)',
    explanation: 'Helicase unwinds DNA by breaking hydrogen bonds between base pairs. It moves along the template using ATP energy.',
  ),
  ReplicationTask(
    task: 'STEP 2: Prevent the unwound single strands from re-annealing (re-pairing) behind helicase.',
    correctEnzyme: 'SSB proteins (Single-Strand Binding)',
    options: ['Helicase', 'SSB proteins (Single-Strand Binding)', 'Primase', 'Gyrase'],
    chapter: 'Molecular Basis Ch 6 (Class 12)',
    explanation: 'SSB proteins stabilise the single-stranded template by binding to them, preventing them from forming hairpin loops or re-annealing.',
  ),
  ReplicationTask(
    task: 'STEP 3: Relieve the topological stress (supercoiling) ahead of the replication fork.',
    correctEnzyme: 'Gyrase / Topoisomerase II',
    options: ['Helicase', 'Ligase', 'Gyrase / Topoisomerase II', 'DNA Pol I'],
    chapter: 'Molecular Basis Ch 6 (Class 12)',
    explanation: 'As helicase unwinds DNA, positive supercoils accumulate ahead. Gyrase (a type II topoisomerase) cuts and re-joins DNA to relieve this tension.',
  ),
  ReplicationTask(
    task: 'STEP 4: Synthesise a short RNA primer to provide a free 3\'-OH group for DNA polymerase.',
    correctEnzyme: 'Primase',
    options: ['DNA Pol III', 'Primase', 'DNA Pol I', 'Ligase'],
    chapter: 'Molecular Basis Ch 6 (Class 12)',
    explanation: 'DNA polymerase CANNOT start synthesis de novo — it needs a primer with a 3\'-OH. Primase (an RNA polymerase) synthesises 5-10 nucleotide RNA primers.',
  ),
  ReplicationTask(
    task: 'STEP 5: Extend the DNA chain 5\'→3\' at high speed and fidelity on both leading and lagging strands.',
    correctEnzyme: 'DNA Polymerase III',
    options: ['DNA Pol I', 'DNA Pol III', 'Primase', 'Ligase'],
    chapter: 'Molecular Basis Ch 6 (Class 12)',
    explanation: 'DNA Pol III is the main replicative polymerase. It adds deoxyribonucleotides at ~1000 nt/sec with error rate of 1 in 10^7.',
  ),
  ReplicationTask(
    task: 'STEP 6: Remove the RNA primers and replace them with DNA.',
    correctEnzyme: 'DNA Polymerase I',
    options: ['DNA Pol III', 'Ligase', 'DNA Pol I', 'Helicase'],
    chapter: 'Molecular Basis Ch 6 (Class 12)',
    explanation: 'DNA Pol I has 5\'→3\' exonuclease activity to remove RNA primers, and polymerase activity to fill the gap with DNA.',
  ),
  ReplicationTask(
    task: 'STEP 7: Join the Okazaki fragments on the lagging strand by sealing the nicks.',
    correctEnzyme: 'Ligase',
    options: ['Primase', 'Helicase', 'DNA Pol I', 'Ligase'],
    chapter: 'Molecular Basis Ch 6 (Class 12)',
    explanation: 'DNA Ligase seals the phosphodiester bond between adjacent Okazaki fragments using ATP (eukaryotes) or NAD⁺ (prokaryotes).',
  ),
];

// ── Scientific Names for Spell Checker ────────────────────────
class SpellItem {
  final String hint;
  final String answer; // exact spelling including case
  final String chapter;
  const SpellItem({required this.hint, required this.answer, required this.chapter});
}

const List<SpellItem> spellItems = [
  SpellItem(hint: 'The common fruit fly — most studied genetics organism', answer: 'Drosophila melanogaster', chapter: 'Principles of Inheritance Ch 5 (Class 12)'),
  SpellItem(hint: 'The pea plant used by Mendel for genetics experiments', answer: 'Pisum sativum', chapter: 'Principles of Inheritance Ch 5 (Class 12)'),
  SpellItem(hint: 'The tobacco plant (Nicotine source)', answer: 'Nicotiana tabacum', chapter: 'Plant Kingdom Ch 3'),
  SpellItem(hint: 'Common bread mould — first organism used to show one gene-one enzyme', answer: 'Neurospora crassa', chapter: 'Molecular Basis Ch 6 (Class 12)'),
  SpellItem(hint: 'Human roundworm (intestinal parasite)', answer: 'Ascaris lumbricoides', chapter: 'Animal Kingdom Ch 4'),
  SpellItem(hint: 'Malarial parasite (most dangerous species)', answer: 'Plasmodium falciparum', chapter: 'Human Health Ch 8 (Class 12)'),
  SpellItem(hint: 'The organism used by Morgan for linked gene experiments (fruit fly)', answer: 'Drosophila melanogaster', chapter: 'Inheritance Ch 5 (Class 12)'),
  SpellItem(hint: 'Dog tapeworm — example of true endoparasite', answer: 'Taenia solium', chapter: 'Animal Kingdom Ch 4'),
  SpellItem(hint: 'Nitrogen-fixing bacteria found in legume root nodules', answer: 'Rhizobium', chapter: 'Mineral Nutrition Ch 12'),
  SpellItem(hint: 'Free-living nitrogen-fixing bacteria in soil', answer: 'Azotobacter', chapter: 'Mineral Nutrition Ch 12'),
  SpellItem(hint: 'The bacterium that causes typhoid fever', answer: 'Salmonella typhi', chapter: 'Human Health Ch 8 (Class 12)'),
  SpellItem(hint: 'The bacterium causing cholera — produces rice-water stools', answer: 'Vibrio cholerae', chapter: 'Human Health Ch 8 (Class 12)'),
  SpellItem(hint: 'Liverwort — example of a bryophyte', answer: 'Marchantia', chapter: 'Plant Kingdom Ch 3'),
  SpellItem(hint: 'The bacterium used to produce the first recombinant DNA (insulin)', answer: 'Escherichia coli', chapter: 'Biotechnology Ch 11 (Class 12)'),
  SpellItem(hint: 'Pneumonia-causing organism studied by Griffith for transformation', answer: 'Streptococcus pneumoniae', chapter: 'Molecular Basis Ch 6 (Class 12)'),
];

// ── Biological Calendar ────────────────────────────────────────
class CalendarEvent {
  final String event;
  final String year; // year or era
  final String hint;
  final String chapter;
  const CalendarEvent({
    required this.event,
    required this.year,
    required this.hint,
    required this.chapter,
  });
}

const List<CalendarEvent> calendarEvents = [
  CalendarEvent(event: 'Robert Hooke observed dead cells in cork and coined "cell"', year: '1665', hint: 'Hooke used a compound microscope; these were actually dead cell walls.', chapter: 'Cell Ch 8'),
  CalendarEvent(event: 'Antonie van Leeuwenhoek observed live microorganisms ("animalcules")', year: '1676', hint: 'First to observe bacteria and protozoa using simple microscopes he built himself.', chapter: 'The Living World Ch 1'),
  CalendarEvent(event: 'Charles Darwin published "On the Origin of Species"', year: '1859', hint: 'Published after 20 years of delay; Wallace\'s parallel discovery prompted Darwin to publish.', chapter: 'Evolution Ch 7 (Class 12)'),
  CalendarEvent(event: 'Mendel published his laws of inheritance', year: '1865', hint: 'Published in an obscure journal, rediscovered in 1900 by De Vries, Correns, and Tschermak.', chapter: 'Inheritance Ch 5 (Class 12)'),
  CalendarEvent(event: 'Watson and Crick proposed the DNA double helix structure', year: '1953', hint: 'Based on X-ray crystallography data from Rosalind Franklin and Wilkins.', chapter: 'Molecular Basis Ch 6 (Class 12)'),
  CalendarEvent(event: 'Frederick Griffith demonstrated bacterial transformation', year: '1928', hint: 'Used smooth and rough Pneumococcus strains. Showed "transforming principle" could transfer virulence.', chapter: 'Molecular Basis Ch 6 (Class 12)'),
  CalendarEvent(event: 'Avery, MacLeod & McCarty proved DNA is the genetic material', year: '1944', hint: 'Used RNase, DNase, and protease to identify the transforming principle as DNA.', chapter: 'Molecular Basis Ch 6 (Class 12)'),
  CalendarEvent(event: 'Hershey and Chase confirmed DNA as genetic material using phage T2', year: '1952', hint: 'Used radioactive ³⁵S (protein) and ³²P (DNA). Only ³²P entered bacteria.', chapter: 'Molecular Basis Ch 6 (Class 12)'),
  CalendarEvent(event: 'First genetically engineered insulin (Humulin) produced', year: '1982', hint: 'E. coli engineered with human insulin gene. FDA approved it for diabetic patients.', chapter: 'Biotechnology Ch 12 (Class 12)'),
];

// ── Triple Taxonomy Match ─────────────────────────────────────
class TaxonomyTriple {
  final String commonName;
  final String scientificName;
  final String uniqueFeature;
  final String chapter;
  const TaxonomyTriple({
    required this.commonName,
    required this.scientificName,
    required this.uniqueFeature,
    required this.chapter,
  });
}

const List<TaxonomyTriple> taxonomyTriples = [
  TaxonomyTriple(commonName: 'Sea Walnut', scientificName: 'Pleurobrachia', uniqueFeature: 'Bioluminescent comb jelly (Ctenophora)', chapter: 'Animal Kingdom Ch 4'),
  TaxonomyTriple(commonName: 'Sea Pen', scientificName: 'Pennatula', uniqueFeature: 'Colonial cnidarian with pen-like form', chapter: 'Animal Kingdom Ch 4'),
  TaxonomyTriple(commonName: 'Sea Hare', scientificName: 'Aplysia', uniqueFeature: 'Mollusc secretes purple ink for defence', chapter: 'Animal Kingdom Ch 4'),
  TaxonomyTriple(commonName: 'Sea Lily', scientificName: 'Antedon', uniqueFeature: 'Stalked echinoderm (Crinoidea); sessile as adult', chapter: 'Animal Kingdom Ch 4'),
  TaxonomyTriple(commonName: 'Flying Fish', scientificName: 'Exocoetus', uniqueFeature: 'Osteichthyes with enlarged pectoral fins for gliding', chapter: 'Animal Kingdom Ch 4'),
  TaxonomyTriple(commonName: 'Electric Ray', scientificName: 'Torpedo', uniqueFeature: 'Cartilaginous fish (Chondrichthyes) generating 200V', chapter: 'Animal Kingdom Ch 4'),
  TaxonomyTriple(commonName: 'King Cobra', scientificName: 'Ophiophagus hannah', uniqueFeature: 'World\'s longest venomous snake; feeds on other snakes', chapter: 'Animal Kingdom Ch 4'),
  TaxonomyTriple(commonName: 'Balanoglossus', scientificName: 'Balanoglossus', uniqueFeature: 'Hemichordata — has proboscis and gill slits; living fossil', chapter: 'Animal Kingdom Ch 4'),
];
