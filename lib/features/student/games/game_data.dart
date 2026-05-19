/// All NCERT Biology game content data.
/// Sources: Class 11 (kebo1ps) and Class 12 (lebo108) NCERT Biology textbooks.
library game_data;

// ── Diagnosis Chamber ─────────────────────────────────────────
class DiagnosisCase {
  final String title;
  final String symptoms;
  final String disease;
  final String missingNutrient;
  final String chapter;
  final String explanation;
  const DiagnosisCase({
    required this.title,
    required this.symptoms,
    required this.disease,
    required this.missingNutrient,
    required this.chapter,
    required this.explanation,
  });
}

const List<DiagnosisCase> diagnosisCases = [
  DiagnosisCase(
    title: 'Case #1',
    symptoms: 'A 3-year-old child from a low-income household has a swollen abdomen (pot-belly), muscle wasting in limbs, oedema in feet, and light-coloured patchy skin. Diet consists mainly of rice with very little protein.',
    disease: 'Kwashiorkor',
    missingNutrient: 'Protein',
    chapter: 'Digestion & Absorption (Ch 16)',
    explanation: 'Kwashiorkor results from severe protein deficiency despite adequate calorie intake. The swollen belly is due to low albumin levels causing fluid retention (oedema). Characteristic skin patches and hair discolouration also occur.',
  ),
  DiagnosisCase(
    title: 'Case #2',
    symptoms: 'A 2-year-old child has severe muscle and fat wasting giving an emaciated "old man" appearance. Height and weight are far below normal. Diet has been severely restricted in both calories and protein.',
    disease: 'Marasmus',
    missingNutrient: 'Protein & Calories',
    chapter: 'Digestion & Absorption (Ch 16)',
    explanation: 'Marasmus is caused by total starvation — deficiency of both protein and calories. Unlike Kwashiorkor, there is no oedema. The child looks severely wasted with visible ribs and sunken eyes.',
  ),
  DiagnosisCase(
    title: 'Case #3',
    symptoms: 'A sailor has been at sea for 4 months eating only preserved biscuits and salted meat. He now shows bleeding gums, loose teeth, painful swollen joints, and small red spots (petechiae) under the skin.',
    disease: 'Scurvy',
    missingNutrient: 'Vitamin C (Ascorbic Acid)',
    chapter: 'Digestion & Absorption (Ch 16)',
    explanation: 'Vitamin C is essential for collagen synthesis. Its deficiency causes scurvy — collagen in blood vessel walls degrades, causing bleeding. Gums bleed, teeth loosen, and wounds don\'t heal. Citrus fruits prevent it.',
  ),
  DiagnosisCase(
    title: 'Case #4',
    symptoms: 'A 6-month-old exclusively breastfed infant in a northern country (winter) has bowed legs, delayed tooth eruption, and skull deformities. X-rays show abnormal bone density. Mother rarely goes outdoors.',
    disease: 'Rickets',
    missingNutrient: 'Vitamin D',
    chapter: 'Digestion & Absorption (Ch 16)',
    explanation: 'Vitamin D is essential for calcium absorption. Without it, bones don\'t mineralise properly (rickets in children, osteomalacia in adults). Sunlight triggers Vitamin D synthesis in skin. Mother\'s deficiency passed to infant through breast milk.',
  ),
  DiagnosisCase(
    title: 'Case #5',
    symptoms: 'A 40-year-old woman from a coastal town has developed a painless swelling in the front of her neck. She feels fatigued, cold, and has gained weight despite poor appetite. This area uses predominantly rain-fed water.',
    disease: 'Goitre',
    missingNutrient: 'Iodine',
    chapter: 'Chemical Coordination (Ch 22 / Ch 4 Class 12)',
    explanation: 'Iodine is required to synthesise thyroid hormones (T3, T4). In its absence, the thyroid gland enlarges (goitre) trying to capture more iodine. Hypothyroidism follows: low metabolic rate, weight gain, cold intolerance. Iodised salt prevents it.',
  ),
  DiagnosisCase(
    title: 'Case #6',
    symptoms: 'A 10-year-old child living in rural India has difficulty seeing at dusk (night-blindness) and their conjunctiva appears dry with white foamy Bitot\'s spots. Cornea is becoming opaque.',
    disease: 'Night Blindness / Xerophthalmia',
    missingNutrient: 'Vitamin A (Retinol)',
    chapter: 'Digestion & Absorption (Ch 16)',
    explanation: 'Vitamin A forms retinal, the photoreceptor pigment in rod cells needed for dim-light vision. Deficiency causes night-blindness first, then dry eyes (xerophthalmia), and can lead to permanent blindness (keratomalacia). Carrots and leafy vegetables are rich sources.',
  ),
  DiagnosisCase(
    title: 'Case #7',
    symptoms: 'A labourer who eats polished rice daily develops burning feet, swelling of legs, heart palpitations, and confusion. Severe fatigue is reported. No meat, legumes or fortified foods in diet.',
    disease: 'Beri-beri',
    missingNutrient: 'Vitamin B1 (Thiamine)',
    chapter: 'Digestion & Absorption (Ch 16)',
    explanation: 'Thiamine is a coenzyme in pyruvate dehydrogenase (entry into Krebs cycle). Its lack impairs energy metabolism in nerve and heart cells. Wet beri-beri affects the heart; dry beri-beri affects the nervous system. Polishing rice destroys the bran layer containing B vitamins.',
  ),
  DiagnosisCase(
    title: 'Case #8',
    symptoms: 'A young woman develops extreme fatigue, pale skin, rapid heartbeat, and shortness of breath. Blood test shows low haemoglobin (7 g/dL). She follows a strict vegan diet and has heavy menstrual periods.',
    disease: 'Anaemia',
    missingNutrient: 'Iron',
    chapter: 'Digestion & Absorption (Ch 16)',
    explanation: 'Iron is the central atom of haeme in haemoglobin, which carries oxygen. Iron-deficiency anaemia is the most common nutritional deficiency globally. Vegans are at risk as non-haeme iron (plant sources) is less absorbed than haeme iron (meat). Heavy menstruation accelerates iron loss.',
  ),
  DiagnosisCase(
    title: 'Case #9',
    symptoms: 'A 55-year-old strict vegetarian has progressive tingling and numbness in hands and feet, difficulty walking, memory problems, and a very sore, smooth tongue. Blood shows large, pale red blood cells (megaloblastic anaemia).',
    disease: 'Pernicious Anaemia',
    missingNutrient: 'Vitamin B12 (Cobalamin)',
    chapter: 'Digestion & Absorption (Ch 16)',
    explanation: 'B12 is found almost exclusively in animal products. It\'s required for RBC maturation and myelin synthesis. Lack causes megaloblastic anaemia and subacute combined degeneration of the spinal cord. Intrinsic factor from stomach is needed for B12 absorption — its absence causes pernicious anaemia.',
  ),
  DiagnosisCase(
    title: 'Case #10',
    symptoms: 'A person in their 40s develops a scaly skin rash on sun-exposed areas (Casal\'s necklace), chronic diarrhoea, and dementia-like confusion. Diet is primarily maize (corn) with little meat or legumes.',
    disease: 'Pellagra',
    missingNutrient: 'Vitamin B3 (Niacin)',
    chapter: 'Digestion & Absorption (Ch 16)',
    explanation: 'Niacin (B3) is needed as NAD+ in redox reactions. Pellagra = the 4 Ds: Dermatitis, Diarrhoea, Dementia, Death. Maize is rich in leucine which antagonises niacin. Maize also contains niacin in bound form (niacytin) unavailable to humans. Treated with niacin supplements.',
  ),
];

// ── Who Am I ──────────────────────────────────────────────────
class WhoAmIItem {
  final List<String> hints; // from hardest to easiest
  final String answer;
  final String chapter;
  const WhoAmIItem({required this.hints, required this.answer, required this.chapter});
}

const List<WhoAmIItem> whoAmIItems = [
  WhoAmIItem(
    hints: [
      'I am the traffic controller of the cell. Proteins arrive at me and I tag them with a molecular "address label" for delivery.',
      'I am made of a stack of flattened, membrane-bound cisternae.',
      'In plant cells, I am called a dictyosome. I add carbohydrate chains to glycoproteins.',
    ],
    answer: 'Golgi Apparatus',
    chapter: 'Cell: The Unit of Life (Ch 8)',
  ),
  WhoAmIItem(
    hints: [
      'I am the powerhouse of the cell. Everything enters me, but only ATP exits.',
      'I have an outer membrane and a highly folded inner membrane called cristae.',
      'I contain my own circular DNA and ribosomes, suggesting I was once a free-living bacterium.',
    ],
    answer: 'Mitochondria',
    chapter: 'Cell: The Unit of Life (Ch 8)',
  ),
  WhoAmIItem(
    hints: [
      'Without me, there is no life as we know it. I convert light energy into chemical energy.',
      'I contain stacked thylakoids called grana, surrounded by a liquid called stroma.',
      'I am found only in plant and algal cells, and I contain chlorophyll.',
    ],
    answer: 'Chloroplast',
    chapter: 'Photosynthesis (Ch 13)',
  ),
  WhoAmIItem(
    hints: [
      'I am the cell\'s suicide bag. When a cell is damaged or old, I release my contents to destroy it.',
      'I contain hydrolytic enzymes — proteases, lipases, nucleases — in an acidic environment.',
      'I am formed from the Golgi apparatus and am membrane-bound.',
    ],
    answer: 'Lysosome',
    chapter: 'Cell: The Unit of Life (Ch 8)',
  ),
  WhoAmIItem(
    hints: [
      'I am the site of protein synthesis in all living cells — prokaryotes and eukaryotes alike.',
      'In prokaryotes I am 70S; in eukaryotes I am 80S. I have two subunits.',
      'I can be free in the cytoplasm or attached to the endoplasmic reticulum.',
    ],
    answer: 'Ribosome',
    chapter: 'Cell: The Unit of Life (Ch 8)',
  ),
  WhoAmIItem(
    hints: [
      'I am the molecule that reduced NADP+ to NADPH during the light reactions of photosynthesis.',
      'I carry electrons from the electron transport chain to CO2 fixation.',
      'My reduced form is essential for the Calvin cycle to produce G3P.',
    ],
    answer: 'NADPH',
    chapter: 'Photosynthesis (Ch 13)',
  ),
  WhoAmIItem(
    hints: [
      'I am the hormone that acts as a "master regulator." I control all other endocrine glands.',
      'I am secreted by the anterior pituitary and act on the adrenal, thyroid, and gonadal glands.',
      'Examples of my family include TSH, FSH, LH, and ACTH.',
    ],
    answer: 'Tropic Hormones (Pituitary)',
    chapter: 'Chemical Coordination (Ch 22)',
  ),
  WhoAmIItem(
    hints: [
      'I am the only place in the body where CO2 is released from a six-carbon compound to give a four-carbon compound.',
      'I spin endlessly in the matrix of mitochondria, generating NADH, FADH2, and CO2.',
      'I am named after the British biochemist Hans Krebs who discovered me.',
    ],
    answer: 'Krebs Cycle (TCA Cycle)',
    chapter: 'Respiration in Plants (Ch 14)',
  ),
  WhoAmIItem(
    hints: [
      'I am the molecule that all cells use as their immediate energy currency.',
      'I have three phosphate groups. The bond between the last two is a "high-energy bond."',
      'My synthesis by chemiosmosis is catalysed by ATP synthase (Complex V).',
    ],
    answer: 'ATP (Adenosine Triphosphate)',
    chapter: 'Respiration in Plants (Ch 14)',
  ),
  WhoAmIItem(
    hints: [
      'I am the enzyme that cuts DNA at specific palindromic sequences — the scissors of genetic engineering.',
      'I recognise sequences like GAATTC and make staggered cuts, generating "sticky ends."',
      'I was first isolated from bacteria as part of their defence against viral DNA.',
    ],
    answer: 'Restriction Endonuclease',
    chapter: 'Biotechnology (Ch 11 Class 12)',
  ),
  WhoAmIItem(
    hints: [
      'I am a peptide hormone secreted by the beta cells of islets of Langerhans.',
      'I am released when blood glucose rises after a meal. I promote glucose uptake by cells.',
      'My deficiency or insensitivity causes diabetes mellitus.',
    ],
    answer: 'Insulin',
    chapter: 'Chemical Coordination (Ch 22)',
  ),
  WhoAmIItem(
    hints: [
      'I am not a cell, not an organelle, but a protein complex that degrades unwanted proteins in the cell.',
      'I am shaped like a barrel with a lid and mark proteins with ubiquitin tags for destruction.',
      'I maintain protein quality control, clearing misfolded or damaged proteins.',
    ],
    answer: 'Proteasome',
    chapter: 'Biomolecules (Ch 9)',
  ),
  WhoAmIItem(
    hints: [
      'I am the gland that is both endocrine and exocrine.',
      'My exocrine portion produces digestive juices with amylase, lipase, and proteases.',
      'My endocrine portion — the islets of Langerhans — produces insulin and glucagon.',
    ],
    answer: 'Pancreas',
    chapter: 'Digestion & Absorption (Ch 16)',
  ),
  WhoAmIItem(
    hints: [
      'I am the double-stranded helical molecule that stores hereditary information.',
      'My two strands are antiparallel: one runs 5\' to 3\', the other 3\' to 5\'.',
      'Watson and Crick proposed my structure using X-ray data from Rosalind Franklin.',
    ],
    answer: 'DNA',
    chapter: 'Molecular Basis of Inheritance (Ch 6 Class 12)',
  ),
  WhoAmIItem(
    hints: [
      'I am the process by which a mature organism produces offspring.',
      'In its asexual form, I require only one parent. In its sexual form, I involve fusion of gametes.',
      'Vegetative propagation in plants, binary fission in bacteria, and budding in yeast are asexual examples.',
    ],
    answer: 'Reproduction',
    chapter: 'Reproduction in Organisms (Ch 1 Class 12)',
  ),
];

// ── Binary Blitz — Hormone or Enzyme ─────────────────────────
class BinaryItem {
  final String term;
  final String correct; // 'A' or 'B'
  final String labelA;
  final String labelB;
  final String trick;
  const BinaryItem({
    required this.term,
    required this.correct,
    required this.labelA,
    required this.labelB,
    required this.trick,
  });
}

const List<BinaryItem> hormoneOrEnzymeItems = [
  BinaryItem(term: 'Pepsin', correct: 'A', labelA: 'Enzyme', labelB: 'Hormone', trick: 'Pepsin is a protease enzyme in the stomach that digests proteins.'),
  BinaryItem(term: 'Insulin', correct: 'B', labelA: 'Enzyme', labelB: 'Hormone', trick: 'Insulin is a peptide hormone from beta cells of the pancreatic islets.'),
  BinaryItem(term: 'Amylase', correct: 'A', labelA: 'Enzyme', labelB: 'Hormone', trick: 'Salivary amylase breaks starch into maltose. Pancreatic amylase continues digestion.'),
  BinaryItem(term: 'Glucagon', correct: 'B', labelA: 'Enzyme', labelB: 'Hormone', trick: 'Glucagon from alpha cells raises blood glucose — the opposite of insulin.'),
  BinaryItem(term: 'Trypsin', correct: 'A', labelA: 'Enzyme', labelB: 'Hormone', trick: 'Trypsin is a pancreatic protease; its inactive precursor is trypsinogen.'),
  BinaryItem(term: 'Secretin', correct: 'B', labelA: 'Enzyme', labelB: 'Hormone', trick: 'Secretin is the first hormone discovered. It\'s secreted by the duodenum and stimulates pancreatic bicarbonate secretion.'),
  BinaryItem(term: 'Pepsinogen', correct: 'A', labelA: 'Enzyme', labelB: 'Hormone', trick: 'Pepsinogen is a pro-enzyme (zymogen). It is activated to pepsin by HCl in the stomach.'),
  BinaryItem(term: 'ADH (Vasopressin)', correct: 'B', labelA: 'Enzyme', labelB: 'Hormone', trick: 'ADH is released by the posterior pituitary and promotes water reabsorption by kidneys.'),
  BinaryItem(term: 'Renin', correct: 'A', labelA: 'Enzyme', labelB: 'Hormone', trick: 'Renin (from juxtaglomerular cells) is an enzyme that cleaves angiotensinogen. Don\'t confuse with Rennin (enzyme in milk digestion)!'),
  BinaryItem(term: 'Oxytocin', correct: 'B', labelA: 'Enzyme', labelB: 'Hormone', trick: 'Oxytocin is the "love hormone" — posterior pituitary, causes uterine contractions and milk ejection.'),
  BinaryItem(term: 'Cholecystokinin (CCK)', correct: 'B', labelA: 'Enzyme', labelB: 'Hormone', trick: 'CCK from the duodenum stimulates gallbladder to release bile and pancreas to release enzymes.'),
  BinaryItem(term: 'Lipase', correct: 'A', labelA: 'Enzyme', labelB: 'Hormone', trick: 'Lipase breaks down fats (lipids) into fatty acids and glycerol.'),
  BinaryItem(term: 'Thyroxine (T4)', correct: 'B', labelA: 'Enzyme', labelB: 'Hormone', trick: 'Thyroxine is an iodinated tyrosine-based hormone that regulates basal metabolic rate.'),
  BinaryItem(term: 'Maltase', correct: 'A', labelA: 'Enzyme', labelB: 'Hormone', trick: 'Maltase in the small intestine brush border cleaves maltose into two glucose molecules.'),
  BinaryItem(term: 'Testosterone', correct: 'B', labelA: 'Enzyme', labelB: 'Hormone', trick: 'Testosterone is an androgen (steroid hormone) from the Leydig cells of the testes.'),
  BinaryItem(term: 'Rennin', correct: 'A', labelA: 'Enzyme', labelB: 'Hormone', trick: 'Rennin coagulates milk proteins in infants. Different from Renin (kidney enzyme)!'),
  BinaryItem(term: 'Erythropoietin (EPO)', correct: 'B', labelA: 'Enzyme', labelB: 'Hormone', trick: 'EPO is a glycoprotein hormone from the kidneys that stimulates red blood cell production.'),
  BinaryItem(term: 'Sucrase', correct: 'A', labelA: 'Enzyme', labelB: 'Hormone', trick: 'Sucrase (also called invertase) cleaves sucrose into glucose and fructose.'),
  BinaryItem(term: 'Gastrin', correct: 'B', labelA: 'Enzyme', labelB: 'Hormone', trick: 'Gastrin from G cells in the stomach stimulates HCl secretion. It\'s a peptide hormone.'),
  BinaryItem(term: 'Enterokinase', correct: 'A', labelA: 'Enzyme', labelB: 'Hormone', trick: 'Enterokinase (enteropeptidase) is an enzyme that activates trypsinogen → trypsin.'),
  BinaryItem(term: 'Melatonin', correct: 'B', labelA: 'Enzyme', labelB: 'Hormone', trick: 'Melatonin from the pineal gland regulates sleep-wake cycles (circadian rhythms).'),
];

// ── Pathway Poet ──────────────────────────────────────────────
class PathwayPoem {
  final String title;
  final String narrative; // text with ___(a)___ etc.
  final List<String> blanks; // answers in order
  final List<String> labels; // what each blank represents
  final String chapter;
  final String explanation;
  const PathwayPoem({
    required this.title,
    required this.narrative,
    required this.blanks,
    required this.labels,
    required this.chapter,
    required this.explanation,
  });
}

const List<PathwayPoem> pathwayPoems = [
  PathwayPoem(
    title: 'The Light Reactions of Photosynthesis',
    narrative: 'Sunlight strikes ___(a)___, exciting electrons to a high energy state. '
        'These electrons are passed along the ___(b)___ in the thylakoid membrane. '
        'The energy released pumps H⁺ ions, creating a gradient that drives ___(c)___. '
        'At the end, electrons reduce ___(d)___ to ___(e)___, storing energy for the Calvin cycle. '
        'The electrons lost by ___(a)___ are replaced by splitting ___(f)___, releasing O₂.',
    blanks: ['PSII', 'Electron Transport Chain', 'ATP Synthase', 'NADP+', 'NADPH', 'Water'],
    labels: ['(a) First Photosystem', '(b) Electron carrier chain', '(c) ATP-making enzyme', '(d) Electron acceptor', '(e) Reduced form', '(f) Electron donor'],
    chapter: 'Photosynthesis (Ch 13)',
    explanation: 'The Z-scheme: Water → PSII → PQ → Cytochrome b6f → PC → PSI → Fd → NADP+ reductase → NADPH. Photolysis of water releases O₂ as a byproduct.',
  ),
  PathwayPoem(
    title: 'Glycolysis — The Universal First Step',
    narrative: 'Glycolysis begins with ___(a)___ in the cytoplasm. '
        'First, glucose is phosphorylated twice using ___(b)___ molecules of ATP, giving ___(c)___. '
        'This is cleaved into two molecules of ___(d)___. '
        'Each is oxidised to pyruvate, generating ___(e)___ molecules of ATP (net) and ___(f)___ molecules of NADH. '
        'The net yield of glycolysis per glucose is ___(g)___ ATP and ___(f)___ NADH.',
    blanks: ['Glucose', '2', 'Fructose-1,6-bisphosphate', 'PGAL / G3P', '2', '2', '2'],
    labels: ['(a) Starting molecule', '(b) ATP invested', '(c) 6-carbon bisphosphate', '(d) 3-carbon fragment', '(e) Net ATP yield', '(f) NADH produced', '(g) Net ATP'],
    chapter: 'Respiration (Ch 14)',
    explanation: 'Glycolysis: 1 Glucose + 2ATP (investment) → 4ATP (output) = 2 net ATP, 2 NADH, 2 pyruvate. Occurs in cytoplasm, does not require oxygen.',
  ),
  PathwayPoem(
    title: 'The Krebs Cycle',
    narrative: 'Pyruvate enters the mitochondrial matrix and is decarboxylated to ___(a)___, losing one CO₂ and forming NADH. '
        'Acetyl CoA joins with ___(b)___ (4C) to form ___(c)___ (6C). '
        'Through a series of decarboxylations and oxidations, 2 CO₂ are released per turn, along with ___(d)___ NADH, '
        '___(e)___ FADH₂, and ___(f)___ GTP. '
        'Per glucose molecule, the cycle turns ___(g)___ times, as pyruvate gives two acetyl CoA molecules.',
    blanks: ['Acetyl CoA', 'Oxaloacetate (OAA)', 'Citrate', '3', '1', '1', '2'],
    labels: ['(a) 2C compound formed', '(b) Cycle acceptor (4C)', '(c) First product (6C)', '(d) NADH per turn', '(e) FADH₂ per turn', '(f) GTP per turn', '(g) Turns per glucose'],
    chapter: 'Respiration (Ch 14)',
    explanation: 'Krebs cycle: Per glucose → 6 NADH, 2 FADH₂, 2 GTP, 4 CO₂ (total). The cycle regenerates OAA to accept the next Acetyl CoA.',
  ),
  PathwayPoem(
    title: 'The Calvin Cycle (C3 Pathway)',
    narrative: 'CO₂ is fixed by the enzyme ___(a)___ onto ___(b)___ (5C, RuBP), forming two molecules of ___(c)___ (3C). '
        'This is reduced using ___(d)___ and ___(e)___ (from light reactions) to form ___(f)___ (G3P). '
        'Most G3P is used to regenerate ___(b)___ to continue the cycle. '
        'For every ___(g)___ CO₂ fixed, one G3P molecule is gained for sugar synthesis.',
    blanks: ['RuBisCO', 'RuBP', '3-PGA', 'ATP', 'NADPH', 'G3P', '3'],
    labels: ['(a) CO₂-fixing enzyme', '(b) CO₂ acceptor (5C)', '(c) First stable product (3C)', '(d) Energy currency', '(e) Reducing agent', '(f) Sugar phosphate (3C)', '(g) CO₂ needed per G3P'],
    chapter: 'Photosynthesis (Ch 13)',
    explanation: 'RuBisCO is the most abundant enzyme on Earth. For 1 glucose: 6 CO₂ + 18 ATP + 12 NADPH → 1 glucose. 3 CO₂ → 6 G3P → 1 G3P net (5 regenerate RuBP).',
  ),
  PathwayPoem(
    title: 'Nitrogen Fixation & Assimilation',
    narrative: 'Atmospheric nitrogen (N₂) is fixed by the enzyme ___(a)___ found in free-living bacteria like ___(b)___ and symbiotic ___(c)___ in root nodules. '
        'The reaction requires ___(d)___ molecules of ATP per N₂ fixed. '
        'The product, ___(e)___, is then assimilated into amino acids via ___(f)___ (by adding to α-ketoglutarate). '
        'The process is sensitive to ___(g)___, which permanently inactivates nitrogenase.',
    blanks: ['Nitrogenase', 'Azotobacter', 'Rhizobium', '16', 'NH₃ / Ammonia', 'Reductive amination', 'Oxygen'],
    labels: ['(a) Fixing enzyme', '(b) Free-living nitrogen fixer', '(c) Symbiotic bacteria', '(d) ATP molecules used', '(e) Fixed nitrogen product', '(f) Assimilation pathway', '(g) Environmental inhibitor'],
    chapter: 'Mineral Nutrition (Ch 12)',
    explanation: 'N₂ + 8H⁺ + 8e⁻ + 16ATP → 2NH₃ + H₂ + 16ADP. Leghaemoglobin in root nodules protects nitrogenase from O₂. Fixed nitrogen enters amino acids via glutamate/glutamine.',
  ),
];

// ── Descending Order ──────────────────────────────────────────
class OrderChallenge {
  final String category;
  final String instruction;
  final List<String> correctOrder; // already in correct descending/ascending order
  final String orderType; // 'descending' or 'ascending'
  final String chapter;
  const OrderChallenge({
    required this.category,
    required this.instruction,
    required this.correctOrder,
    required this.orderType,
    required this.chapter,
  });
}

const List<OrderChallenge> orderChallenges = [
  OrderChallenge(
    category: 'Taxonomic Hierarchy',
    instruction: 'Arrange from HIGHEST to LOWEST taxonomic rank',
    correctOrder: ['Kingdom', 'Phylum', 'Class', 'Order', 'Family', 'Genus', 'Species'],
    orderType: 'descending',
    chapter: 'The Living World (Ch 1)',
  ),
  OrderChallenge(
    category: 'Ecological Organisation',
    instruction: 'Arrange from HIGHEST to LOWEST level of organisation',
    correctOrder: ['Biosphere', 'Ecosystem', 'Community', 'Population', 'Organism', 'Organ System', 'Cell'],
    orderType: 'descending',
    chapter: 'Ecosystems (Ch 14 Class 12)',
  ),
  OrderChallenge(
    category: 'Cell Division Stages (Mitosis)',
    instruction: 'Arrange mitotic phases in CORRECT chronological order',
    correctOrder: ['Prophase', 'Metaphase', 'Anaphase', 'Telophase', 'Cytokinesis'],
    orderType: 'ascending',
    chapter: 'Cell Cycle (Ch 10)',
  ),
  OrderChallenge(
    category: 'Blood Pressure in Circulatory System',
    instruction: 'Arrange from HIGHEST to LOWEST blood pressure',
    correctOrder: ['Aorta', 'Arteries', 'Arterioles', 'Capillaries', 'Venules', 'Veins', 'Vena Cava'],
    orderType: 'descending',
    chapter: 'Circulation (Ch 18)',
  ),
  OrderChallenge(
    category: 'Trophic Levels (Energy Flow)',
    instruction: 'Arrange from FIRST to LAST trophic level',
    correctOrder: ['Producers', 'Primary Consumers', 'Secondary Consumers', 'Tertiary Consumers', 'Decomposers'],
    orderType: 'ascending',
    chapter: 'Ecosystems (Ch 14 Class 12)',
  ),
  OrderChallenge(
    category: 'Plant Groups (Complexity)',
    instruction: 'Arrange from LEAST to MOST evolved/complex',
    correctOrder: ['Bryophyta', 'Pteridophyta', 'Gymnosperms', 'Angiosperms'],
    orderType: 'ascending',
    chapter: 'Plant Kingdom (Ch 3)',
  ),
  OrderChallenge(
    category: 'Digestion Sequence',
    instruction: 'Arrange in the ORDER food passes through the digestive tract',
    correctOrder: ['Mouth', 'Oesophagus', 'Stomach', 'Duodenum', 'Jejunum', 'Ileum', 'Colon', 'Rectum'],
    orderType: 'ascending',
    chapter: 'Digestion (Ch 16)',
  ),
  OrderChallenge(
    category: 'Embryonic Development (Mammals)',
    instruction: 'Arrange in CORRECT chronological order of embryo development',
    correctOrder: ['Fertilisation', 'Zygote', 'Morula', 'Blastula', 'Gastrula', 'Implantation', 'Organogenesis'],
    orderType: 'ascending',
    chapter: 'Human Reproduction (Ch 3 Class 12)',
  ),
];

// ── What's Wrong ──────────────────────────────────────────────
class WrongStatement {
  final String statement;
  final String wrongWord;
  final String correction;
  final String chapter;
  const WrongStatement({
    required this.statement,
    required this.wrongWord,
    required this.correction,
    required this.chapter,
  });
}

const List<WrongStatement> wrongStatements = [
  WrongStatement(
    statement: 'Pneumonia is a viral disease that primarily affects the joints and causes severe arthritis.',
    wrongWord: 'viral ... joints ... arthritis',
    correction: 'Bacterial disease (Streptococcus pneumoniae) affecting the alveoli of the lungs.',
    chapter: 'Human Health & Disease (Ch 8 Class 12)',
  ),
  WrongStatement(
    statement: 'Mitochondria are found in prokaryotic cells and are the site of anaerobic respiration.',
    wrongWord: 'prokaryotic ... anaerobic',
    correction: 'Mitochondria are in eukaryotic cells and are the site of aerobic respiration.',
    chapter: 'Cell (Ch 8)',
  ),
  WrongStatement(
    statement: 'RNA uses thymine (T) as a base instead of uracil (U), while DNA uses uracil.',
    wrongWord: 'thymine ... instead of uracil ... DNA uses uracil',
    correction: 'RNA uses uracil (U) instead of thymine; DNA uses thymine.',
    chapter: 'Molecular Basis (Ch 6 Class 12)',
  ),
  WrongStatement(
    statement: 'The process of photosynthesis converts light energy to ATP and releases CO₂ as a by-product.',
    wrongWord: 'CO₂ as a by-product',
    correction: 'Oxygen (O₂) is released as a by-product from water photolysis.',
    chapter: 'Photosynthesis (Ch 13)',
  ),
  WrongStatement(
    statement: 'Insulin is secreted by the alpha cells of the islets of Langerhans in the pancreas.',
    wrongWord: 'alpha cells',
    correction: 'Insulin is secreted by beta cells. Alpha cells secrete glucagon.',
    chapter: 'Chemical Coordination (Ch 22)',
  ),
  WrongStatement(
    statement: 'Transpiration occurs predominantly through the roots and provides the main upward pull for water in the xylem.',
    wrongWord: 'roots',
    correction: 'Transpiration occurs through leaves (stomata and cuticle), creating suction that pulls water up.',
    chapter: 'Transport in Plants (Ch 11)',
  ),
  WrongStatement(
    statement: 'The ABO blood group system is controlled by two alleles (IA and IB) and follows incomplete dominance.',
    wrongWord: 'two alleles ... incomplete dominance',
    correction: 'ABO is controlled by three alleles (IA, IB, i) and shows co-dominance (IA and IB are both expressed).',
    chapter: 'Inheritance (Ch 5 Class 12)',
  ),
  WrongStatement(
    statement: 'In the reflex arc, the signal travels: Receptor → Efferent neuron → Spinal cord → Afferent neuron → Effector.',
    wrongWord: 'Efferent neuron → Spinal cord → Afferent neuron',
    correction: 'Correct: Receptor → Afferent neuron → Spinal cord → Efferent neuron → Effector.',
    chapter: 'Neural Control (Ch 21)',
  ),
  WrongStatement(
    statement: 'Ribosomes in eukaryotes are 70S and are found attached to the smooth endoplasmic reticulum.',
    wrongWord: '70S ... smooth ER',
    correction: 'Eukaryotic ribosomes are 80S. They attach to rough ER (not smooth ER).',
    chapter: 'Cell (Ch 8)',
  ),
  WrongStatement(
    statement: 'In meiosis I, sister chromatids separate, while in meiosis II, homologous chromosomes separate.',
    wrongWord: 'sister chromatids separate ... meiosis I ... homologous ... meiosis II',
    correction: 'In meiosis I, homologous chromosomes separate. In meiosis II, sister chromatids separate.',
    chapter: 'Cell Cycle (Ch 10)',
  ),
  WrongStatement(
    statement: 'The Hardy-Weinberg principle states that allele frequencies in a population change each generation due to natural selection.',
    wrongWord: 'change each generation due to natural selection',
    correction: 'H-W states allele frequencies remain CONSTANT across generations in the absence of disturbing forces.',
    chapter: 'Evolution (Ch 7 Class 12)',
  ),
  WrongStatement(
    statement: 'Bile is produced by the gallbladder and contains enzymes that digest fats.',
    wrongWord: 'gallbladder ... enzymes',
    correction: 'Bile is produced by the LIVER and STORED in the gallbladder. It contains bile salts (not enzymes) that emulsify fats.',
    chapter: 'Digestion (Ch 16)',
  ),
];

// ── Garbage Collector ─────────────────────────────────────────
class WasteItem {
  final String molecule;
  final String correctBin; // index into bins
  final List<String> bins;
  final String fact;
  final String chapter;
  const WasteItem({
    required this.molecule,
    required this.correctBin,
    required this.bins,
    required this.fact,
    required this.chapter,
  });
}

const List<WasteItem> wasteItems = [
  WasteItem(molecule: 'Urea', correctBin: 'Mammals', bins: ['Mammals', 'Birds/Reptiles', 'Aquatic (Bony Fish)'], fact: 'Mammals convert toxic ammonia to urea (ureotelic), using the ornithine cycle. Less toxic, requires water.', chapter: 'Excretion (Ch 19)'),
  WasteItem(molecule: 'Uric Acid', correctBin: 'Birds/Reptiles', bins: ['Mammals', 'Birds/Reptiles', 'Aquatic (Bony Fish)'], fact: 'Birds, reptiles, and insects excrete uric acid (uricotelic) — insoluble, can be stored in egg, conserves water.', chapter: 'Excretion (Ch 19)'),
  WasteItem(molecule: 'Ammonia', correctBin: 'Aquatic (Bony Fish)', bins: ['Mammals', 'Birds/Reptiles', 'Aquatic (Bony Fish)'], fact: 'Aquatic animals excrete ammonia directly (ammonotelic) — very toxic but water dilutes it immediately.', chapter: 'Excretion (Ch 19)'),
  WasteItem(molecule: 'CO₂', correctBin: 'All organisms', bins: ['Plants only', 'Animals only', 'All organisms'], fact: 'CO₂ is a universal metabolic waste product of aerobic respiration. Excreted via lungs (animals) or stomata (plants).', chapter: 'Excretion (Ch 19)'),
  WasteItem(molecule: 'Uric Acid (Insects)', correctBin: 'Insects/Arachnids', bins: ['Mammals', 'Birds/Reptiles', 'Insects/Arachnids'], fact: 'Insects also excrete uric acid — perfect for conserving water in dry environments.', chapter: 'Excretion (Ch 19)'),
  WasteItem(molecule: 'Creatinine', correctBin: 'Mammals', bins: ['Mammals', 'Birds', 'Fish'], fact: 'Creatinine is a waste from creatine phosphate breakdown in muscles. Excreted by kidneys in urine.', chapter: 'Excretion (Ch 19)'),
  WasteItem(molecule: 'Bilirubin', correctBin: 'Mammals', bins: ['Mammals', 'Birds/Reptiles', 'Fish'], fact: 'Bilirubin from haemoglobin breakdown gives urine its yellow colour. Excreted via bile and urine.', chapter: 'Digestion (Ch 16)'),
  WasteItem(molecule: 'Water (as vapour)', correctBin: 'All organisms', bins: ['Plants only', 'Animals only', 'All organisms'], fact: 'Water is lost by all organisms — transpiration in plants, exhalation and urine in animals.', chapter: 'Transport in Plants (Ch 11)'),
];

// ── Punnett Square ────────────────────────────────────────────
class PunnettProblem {
  final String cross;
  final String question;
  final String genotypeRatio;
  final String phenotypeRatio;
  final String phenotypeDescriptions;
  final String chapter;
  final String hint;
  const PunnettProblem({
    required this.cross,
    required this.question,
    required this.genotypeRatio,
    required this.phenotypeRatio,
    required this.phenotypeDescriptions,
    required this.chapter,
    required this.hint,
  });
}

const List<PunnettProblem> punnettProblems = [
  PunnettProblem(
    cross: 'Tt × tt (Test Cross)',
    question: 'A Tall pea plant (Tt) is test-crossed with a dwarf plant (tt).\nWhat are the ratios in the offspring?',
    genotypeRatio: '1 Tt : 1 tt',
    phenotypeRatio: '1 : 1',
    phenotypeDescriptions: '1 Tall : 1 Dwarf',
    chapter: 'Principles of Inheritance (Ch 5 Class 12)',
    hint: 'In a test cross, one parent is always homozygous recessive (tt). Half offspring get T from Tall parent.',
  ),
  PunnettProblem(
    cross: 'Tt × Tt (F2 Generation)',
    question: 'Two F1 Tall pea plants (Tt) are crossed.\nWhat are the F2 genotypic and phenotypic ratios?',
    genotypeRatio: '1 TT : 2 Tt : 1 tt',
    phenotypeRatio: '3 : 1',
    phenotypeDescriptions: '3 Tall : 1 Dwarf',
    chapter: 'Principles of Inheritance (Ch 5 Class 12)',
    hint: 'Mendel\'s Law of Segregation. TT and Tt both show Tall phenotype since T is dominant. Only tt is dwarf.',
  ),
  PunnettProblem(
    cross: 'Red (RR) × White (rr) in Snapdragon',
    question: 'Red snapdragon (RR) × White snapdragon (rr).\nWhat colour are the F1 flowers? What about F2?',
    genotypeRatio: 'F1: All Rr | F2: 1 RR : 2 Rr : 1 rr',
    phenotypeRatio: 'F1: All Pink | F2: 1 : 2 : 1',
    phenotypeDescriptions: 'F2: 1 Red : 2 Pink : 1 White (Incomplete dominance)',
    chapter: 'Principles of Inheritance (Ch 5 Class 12)',
    hint: 'Incomplete dominance: neither allele fully masks the other. Heterozygote (Rr) is intermediate (pink).',
  ),
  PunnettProblem(
    cross: 'TTYY × ttyy (Dihybrid)',
    question: 'Pure Tall Yellow (TTYY) × Dwarf Green (ttyy).\nWhat is the F2 phenotypic ratio?',
    genotypeRatio: '16 combinations',
    phenotypeRatio: '9 : 3 : 3 : 1',
    phenotypeDescriptions: '9 Tall Yellow : 3 Tall Green : 3 Dwarf Yellow : 1 Dwarf Green',
    chapter: 'Principles of Inheritance (Ch 5 Class 12)',
    hint: 'Mendel\'s Law of Independent Assortment. F1 is all TtYy. F2 follows 9:3:3:1 dihybrid ratio.',
  ),
  PunnettProblem(
    cross: 'ABO Blood Group: IA × IB',
    question: 'Mother has blood group IA IA (Group A). Father has IBIB (Group B).\nWhat blood group(s) can their children have?',
    genotypeRatio: 'All IA IB',
    phenotypeRatio: '100% AB',
    phenotypeDescriptions: 'All children will have Group AB blood (co-dominance)',
    chapter: 'Principles of Inheritance (Ch 5 Class 12)',
    hint: 'Both IA and IB are co-dominant — both alleles are expressed. There is no recessive allele here.',
  ),
];

// ── Assassin Protein ──────────────────────────────────────────
class AssassinScenario {
  final String scenario;
  final List<String> suspects;
  final int culpritIndex;
  final String explanation;
  final String chapter;
  const AssassinScenario({
    required this.scenario,
    required this.suspects,
    required this.culpritIndex,
    required this.explanation,
    required this.chapter,
  });
}

const List<AssassinScenario> assassinScenarios = [
  AssassinScenario(
    scenario: 'A muscle cell is unable to RELAX after contraction. Calcium ions are not being pumped back into the sarcoplasmic reticulum. The myosin-actin cross-bridges remain attached. Identify the faulty molecule.',
    suspects: ['Myosin', 'Actin', 'Calcium ATPase (SERCA)', 'Troponin'],
    culpritIndex: 2,
    explanation: 'SERCA (Sarcoplasmic/Endoplasmic Reticulum Calcium ATPase) pumps Ca²⁺ back into the SR. Without it, Ca²⁺ remains in the cytoplasm, troponin stays activated, and the muscle cannot relax (rigor mortis-like state).',
    chapter: 'Locomotion & Movement (Ch 20)',
  ),
  AssassinScenario(
    scenario: 'A cell cannot divide. The chromosomes align at the metaphase plate perfectly, but sister chromatids refuse to separate in anaphase. Which molecule is failing?',
    suspects: ['Spindle fibres (Tubulin)', 'Cohesins (Holding chromatids)', 'Securin', 'Separase enzyme'],
    culpritIndex: 3,
    explanation: 'Separase is the enzyme that cleaves cohesins to allow sister chromatid separation in anaphase. It is activated when securin is degraded by APC/C. If separase fails, chromatids cannot separate.',
    chapter: 'Cell Cycle (Ch 10)',
  ),
  AssassinScenario(
    scenario: 'A patient with myasthenia gravis has muscle weakness because nerve signals cannot trigger muscle contraction. The neuromuscular junction is the crime scene. Which molecule is being destroyed?',
    suspects: ['Acetylcholinesterase', 'Nicotinic Acetylcholine Receptors (nAChR)', 'Acetylcholine (ACh)', 'Voltage-gated Na⁺ channels'],
    culpritIndex: 1,
    explanation: 'In myasthenia gravis, autoantibodies destroy nicotinic ACh receptors on the muscle membrane. Even when ACh is released normally, it cannot bind and trigger muscle depolarization.',
    chapter: 'Neural Control (Ch 21)',
  ),
  AssassinScenario(
    scenario: 'A person ingests a fungal toxin (amatoxin from Amanita mushroom). Within hours, they stop making ANY proteins. The liver is failing. What specific molecular target has been destroyed?',
    suspects: ['Ribosome (80S)', 'RNA Polymerase II', 'tRNA synthetase', 'mRNA spliceosomes'],
    culpritIndex: 1,
    explanation: 'α-amanitin specifically inhibits RNA Polymerase II, which transcribes all protein-coding genes (mRNA). Without mRNA, ribosomes cannot translate proteins. The liver, which has high protein synthesis, fails first.',
    chapter: 'Molecular Basis (Ch 6 Class 12)',
  ),
  AssassinScenario(
    scenario: 'A patient cannot digest starch in their mouth or small intestine. Endoscopy shows the pancreas is intact. Blood tests show no pancreatic enzyme issues. Saliva appears watery. Which gland is malfunctioning?',
    suspects: ['Liver', 'Pancreas', 'Salivary glands (Parotid)', 'Stomach parietal cells'],
    culpritIndex: 2,
    explanation: 'Salivary amylase (ptyalin) from the parotid glands begins starch digestion. If salivary glands fail, starch digestion is delayed (though pancreatic amylase eventually compensates). This describes dysfunction of salivary glands specifically.',
    chapter: 'Digestion (Ch 16)',
  ),
  AssassinScenario(
    scenario: 'A cell in the light-independent reactions has normal ATP and NADPH. But CO₂ cannot be fixed. The cycle is completely stopped. Which enzyme is the assassin\'s target?',
    suspects: ['ATP Synthase', 'RuBisCO (RuBP carboxylase)', 'Phosphoglycerate kinase', 'NADP reductase'],
    culpritIndex: 1,
    explanation: 'RuBisCO (Ribulose-1,5-bisphosphate carboxylase/oxygenase) catalyses the first step of CO₂ fixation in the Calvin cycle. Without it, CO₂ cannot attach to RuBP, and the entire cycle stops.',
    chapter: 'Photosynthesis (Ch 13)',
  ),
];

// ── Ploidy Patrol ─────────────────────────────────────────────
class PloidyQuestion {
  final String scenario;
  final String organism;
  final String stage;
  final String correctPloidy;
  final String chromosomeNumber;
  final String explanation;
  final String chapter;
  const PloidyQuestion({
    required this.scenario,
    required this.organism,
    required this.stage,
    required this.correctPloidy,
    required this.chromosomeNumber,
    required this.explanation,
    required this.chapter,
  });
}

const List<PloidyQuestion> ploidyQuestions = [
  PloidyQuestion(
    scenario: 'A diploid moss (2n = 24) undergoes meiosis to form spores.',
    organism: 'Moss (Bryophyte)',
    stage: 'Spores',
    correctPloidy: 'n (Haploid)',
    chromosomeNumber: '12',
    explanation: 'Meiosis halves the chromosome number. Bryophyte spores are haploid (n). The dominant phase in mosses is the gametophyte (n), unlike vascular plants.',
    chapter: 'Plant Kingdom (Ch 3)',
  ),
  PloidyQuestion(
    scenario: 'A human primary spermatocyte (2n = 46) completes meiosis I.',
    organism: 'Human Male',
    stage: 'Secondary spermatocyte (after meiosis I)',
    correctPloidy: 'n (but chromosomes are still double-stranded)',
    chromosomeNumber: '23',
    explanation: 'After meiosis I, homologous chromosomes separate → secondary spermatocyte has 23 chromosomes but each chromosome still has 2 sister chromatids. True haploid genomes come after meiosis II.',
    chapter: 'Human Reproduction (Ch 3 Class 12)',
  ),
  PloidyQuestion(
    scenario: 'The endosperm of an angiosperm (2n = 14) forms after triple fusion.',
    organism: 'Angiosperm',
    stage: 'Endosperm nucleus (after triple fusion)',
    correctPloidy: '3n (Triploid)',
    chromosomeNumber: '21',
    explanation: 'Triple fusion = 2 polar nuclei (n + n = 2n) + 1 sperm (n) → 3n endosperm. This is unique to angiosperms (double fertilisation). The endosperm nourishes the developing embryo.',
    chapter: 'Sexual Reproduction in Flowering Plants (Ch 2 Class 12)',
  ),
  PloidyQuestion(
    scenario: 'A fern sporophyte (2n = 22) produces spores via meiosis. These spores germinate into a prothallus. What is the ploidy of the prothallus?',
    organism: 'Fern (Pteridophyte)',
    stage: 'Prothallus (gametophyte)',
    correctPloidy: 'n (Haploid)',
    chromosomeNumber: '11',
    explanation: 'Fern spores (n) germinate into a haploid prothallus — the gametophyte generation. The prothallus produces archegonia (eggs) and antheridia (sperm). After fertilisation, the sporophyte (2n) grows from it.',
    chapter: 'Plant Kingdom (Ch 3)',
  ),
  PloidyQuestion(
    scenario: 'After fertilisation in humans, the zygote undergoes cleavage to form an 8-cell stage morula. What is its ploidy?',
    organism: 'Human',
    stage: '8-cell morula',
    correctPloidy: '2n (Diploid)',
    chromosomeNumber: '46',
    explanation: 'Fertilisation restores the diploid number (2n = 46). All subsequent mitotic divisions (cleavage) maintain 2n. Every somatic cell of the new individual will have 46 chromosomes.',
    chapter: 'Human Reproduction (Ch 3 Class 12)',
  ),
  PloidyQuestion(
    scenario: 'A wheat plant (2n = 42) undergoes meiosis. What is the chromosome number in its pollen grain?',
    organism: 'Wheat (Hexaploid)',
    stage: 'Pollen grain (male gametophyte)',
    correctPloidy: 'n (Haploid)',
    chromosomeNumber: '21',
    explanation: 'Pollen grains are haploid (n = 21 in wheat). They represent the male gametophyte generation. The pollen grain contains a tube cell nucleus and a generative nucleus (which divides into 2 male gametes).',
    chapter: 'Reproduction in Flowering Plants (Ch 2 Class 12)',
  ),
];

// ── Invader from Abiotic World ────────────────────────────────
class InvaderScenario {
  final String alert;
  final List<String> defenses;
  final int correctIndex;
  final String category; // 'Physical', 'Chemical', 'Specific', 'Non-specific'
  final String explanation;
  final String chapter;
  const InvaderScenario({
    required this.alert,
    required this.defenses,
    required this.correctIndex,
    required this.category,
    required this.explanation,
    required this.chapter,
  });
}

const List<InvaderScenario> invaderScenarios = [
  InvaderScenario(
    alert: '⚠️ ALERT: Foreign particles entering the trachea! Non-living dust particles detected!',
    defenses: ['Activate B-Lymphocytes (Antibody production)', 'Increase Mucus Secretion + Ciliary action', 'Release Histamine', 'Deploy Neutrophils'],
    correctIndex: 1,
    category: 'Physical Barrier (Non-specific)',
    explanation: 'Dust is abiotic — it does not trigger the immune system. The respiratory tract uses physical barriers: mucus traps particles, cilia sweep them up to be coughed/sneezed out. B-cells would be overkill against dust.',
    chapter: 'Human Health & Disease (Ch 8 Class 12)',
  ),
  InvaderScenario(
    alert: '⚠️ ALERT: Staphylococcus aureus bacteria detected in a skin wound! Infection spreading!',
    defenses: ['Sneeze reflex', 'Tears (Lysozyme)', 'Activate T-Killer Lymphocytes', 'Neutrophil phagocytosis + Inflammation'],
    correctIndex: 3,
    category: 'Innate (Non-specific) Cellular',
    explanation: 'Bacteria trigger the first line of cellular defence: neutrophils arrive via inflammation and engulf bacteria (phagocytosis). T-killer cells are for viral infections of body cells. Sneezing is for the respiratory tract.',
    chapter: 'Human Health & Disease (Ch 8 Class 12)',
  ),
  InvaderScenario(
    alert: '⚠️ ALERT: Influenza virus has entered respiratory epithelial cells and is replicating!',
    defenses: ['Antibodies (B-cell mediated)', 'Interferon production by infected cells', 'Neutrophil phagocytosis', 'Mucus barrier'],
    correctIndex: 1,
    category: 'Innate Antiviral Response',
    explanation: 'Virus-infected cells secrete interferons — proteins that signal neighbouring cells to increase antiviral defences. This is the immediate innate antiviral response BEFORE the adaptive immune system (antibodies) takes over (which takes days).',
    chapter: 'Human Health & Disease (Ch 8 Class 12)',
  ),
  InvaderScenario(
    alert: '⚠️ ALERT: Second exposure to the same antigen detected! Memory cells are present from previous encounter!',
    defenses: ['Primary immune response (slow, IgM)', 'Secondary immune response (fast, IgG)', 'Innate response only', 'MHC-I presentation only'],
    correctIndex: 1,
    category: 'Adaptive (Specific) Immunity',
    explanation: 'Memory B and T cells from the first exposure respond rapidly and produce large quantities of high-affinity IgG antibodies. This is the principle behind vaccination — faster and stronger secondary response.',
    chapter: 'Human Health & Disease (Ch 8 Class 12)',
  ),
  InvaderScenario(
    alert: '⚠️ ALERT: Transplanted kidney is being attacked! Host\'s immune system is rejecting the organ!',
    defenses: ['B-cells releasing antibodies', 'T-helper cells activating macrophages', 'T-killer (Cytotoxic T) cells attacking transplant', 'NK cells against virus'],
    correctIndex: 2,
    category: 'Cell-mediated Immunity',
    explanation: 'Organ rejection is primarily mediated by cytotoxic T-cells that recognise foreign MHC molecules on donor cells. This is why immunosuppressant drugs are given after transplantation.',
    chapter: 'Human Health & Disease (Ch 8 Class 12)',
  ),
];

// ── Antakshari terms (valid NCERT biology words) ───────────────
const List<String> ncertBioTerms = [
  'GLYCOLYSIS', 'SUCROSE', 'ENDOSPERM', 'MITOSIS', 'SYNAPSE',
  'ENZYME', 'EXOCYTOSIS', 'STROMA', 'ALEURONE', 'EPIDERMIS',
  'SPERMATOGENESIS', 'SERTOLI', 'ISLETS', 'STOMATA', 'ANGIOSPERMS',
  'SPOROPHYTE', 'EPITHELIUM', 'MEIOSIS', 'SENESCENCE', 'ECOSYSTEM',
  'MELANIN', 'NEPHRON', 'NUCLEOSOME', 'EUKARYOTE', 'EMBRYO',
  'OSMOREGULATION', 'NUCLEOTIDE', 'ECTODERM', 'MESOPHYLL', 'LEUCOCYTE',
  'ESTROGEN', 'NEURON', 'NICHE', 'EXON', 'NITROGEN', 'NUCLEOTIDE',
  'ERYTHROCYTE', 'ENDODERMIS', 'ESTERASE', 'EVAPOTRANSPIRATION',
  'NEMATODE', 'ECDYSONE', 'EMBRYOGENESIS', 'ENDONUCLEASE',
  'ALDOSTERONE', 'EXOSKELETON', 'EOSINOPHIL', 'ENDOCRINE',
  'LYMPHOCYTE', 'EPISTASIS', 'EVOLUTION', 'NEODARWINISM',
  'MYELIN', 'NUCLEOLUS', 'ENDODERM', 'MESODERM', 'MERISTEM',
  'MORPHOGENESIS', 'SEROTONIN', 'NITROBACTER', 'RHIZOBIUM',
  'URETHRA', 'ACETYLCHOLINE', 'ENZYMOLOGY', 'ELBOW', 'EMBRYOLOGY',
];

// ── Root Word Botany ──────────────────────────────────────────
class RootWordItem {
  final String term;
  final List<Map<String, String>> roots; // [{root, meaning}]
  final String bonus;
  final String bonusAnswer;
  final String chapter;
  const RootWordItem({
    required this.term,
    required this.roots,
    required this.bonus,
    required this.bonusAnswer,
    required this.chapter,
  });
}

const List<RootWordItem> rootWordItems = [
  RootWordItem(
    term: 'Osteichthyes',
    roots: [{'root': 'Osteo', 'meaning': 'Bone'}, {'root': 'Ichthyes', 'meaning': 'Fish'}],
    bonus: 'The contrasting class with cartilaginous skeleton is...?',
    bonusAnswer: 'Chondrichthyes',
    chapter: 'Animal Kingdom (Ch 4)',
  ),
  RootWordItem(
    term: 'Photosynthesis',
    roots: [{'root': 'Photo', 'meaning': 'Light'}, {'root': 'Synthesis', 'meaning': 'Making/Building'}],
    bonus: 'What is the term for the breakdown of glucose using light energy in some bacteria?',
    bonusAnswer: 'Photophosphorylation',
    chapter: 'Photosynthesis (Ch 13)',
  ),
  RootWordItem(
    term: 'Glycolysis',
    roots: [{'root': 'Glyco', 'meaning': 'Sugar/Glucose'}, {'root': 'Lysis', 'meaning': 'Breaking down'}],
    bonus: 'What is the enzyme that catalyses the first step of glycolysis?',
    bonusAnswer: 'Hexokinase',
    chapter: 'Respiration (Ch 14)',
  ),
  RootWordItem(
    term: 'Endosymbiosis',
    roots: [{'root': 'Endo', 'meaning': 'Within/Inside'}, {'root': 'Symbiosis', 'meaning': 'Living together'}],
    bonus: 'Which organelles are explained by endosymbiotic theory?',
    bonusAnswer: 'Mitochondria and Chloroplasts',
    chapter: 'Cell (Ch 8)',
  ),
  RootWordItem(
    term: 'Plasmolysis',
    roots: [{'root': 'Plasma', 'meaning': 'Cell contents/Protoplasm'}, {'root': 'Lysis', 'meaning': 'Loosening/Breaking'}],
    bonus: 'What condition causes plasmolysis? (The type of solution)',
    bonusAnswer: 'Hypertonic solution',
    chapter: 'Transport in Plants (Ch 11)',
  ),
  RootWordItem(
    term: 'Mitochondria',
    roots: [{'root': 'Mito', 'meaning': 'Thread'}, {'root': 'Chondria', 'meaning': 'Granule/Cartilage'}],
    bonus: 'The inner membrane folds of mitochondria are called?',
    bonusAnswer: 'Cristae',
    chapter: 'Cell (Ch 8)',
  ),
  RootWordItem(
    term: 'Meristematic',
    roots: [{'root': 'Meristos', 'meaning': 'Divisible (Greek)'}, {'root': 'atic', 'meaning': 'Relating to'}],
    bonus: 'Meristematic cells at the root tip are found in which zone?',
    bonusAnswer: 'Zone of cell division (Apical meristem)',
    chapter: 'Anatomy of Plants (Ch 6)',
  ),
];
