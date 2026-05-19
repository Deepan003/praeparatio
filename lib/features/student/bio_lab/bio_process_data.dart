import 'package:flutter/material.dart';

class BioProcess {
  final String id;
  final String title;
  final String chapter;
  final int classLevel;
  final String emoji;
  final Color color;
  final String description;
  final List<String> keyPoints;
  final List<BioStep> steps;

  const BioProcess({
    required this.id,
    required this.title,
    required this.chapter,
    required this.classLevel,
    required this.emoji,
    required this.color,
    required this.description,
    required this.keyPoints,
    required this.steps,
  });
}

class BioStep {
  final String title;
  final String detail;
  final IconData icon;

  const BioStep({
    required this.title,
    required this.detail,
    required this.icon,
  });
}

// ── Colours per chapter ────────────────────────────────────────
const _repro   = Color(0xFFE91E8C);
const _mol     = Color(0xFF3F51B5);
const _cell    = Color(0xFF009688);
const _photo   = Color(0xFF4CAF50);
const _resp    = Color(0xFFFF5722);
const _circ    = Color(0xFFF44336);
const _neuro   = Color(0xFF9C27B0);
const _plant   = Color(0xFF795548);
const _excrete = Color(0xFF0097A7);
const _muscle  = Color(0xFFFF9800);
const _biotech = Color(0xFF607D8B);

const List<BioProcess> bioProcesses = [

  // ════════════════════════════════ CLASS 12 ═══════════════════════════════

  // ── Sexual Reproduction in Flowering Plants ───────────────────────────────
  BioProcess(
    id: 'megasporogenesis',
    title: 'Megasporogenesis',
    chapter: 'Sexual Reproduction in Flowering Plants',
    classLevel: 12,
    emoji: '🌸',
    color: _repro,
    description: 'Formation of female gametophyte (embryo sac) from megaspore mother cell inside the ovule. A type of meiotic division followed by mitotic divisions.',
    keyPoints: [
      'Occurs inside the nucellus of the ovule',
      'Megaspore mother cell (MMC) is 2n → undergoes meiosis',
      'Linear tetrad of 4 megaspores (n) formed',
      '3 megaspores degenerate; 1 functional (chalazal end)',
      '3 mitotic divisions → 8-nucleate embryo sac (Polygonum type)',
      'Final 7-celled structure: 3 antipodals, 2 synergids, 1 egg, 1 central cell (2 polar nuclei)',
    ],
    steps: [
      BioStep(title: 'Megaspore Mother Cell', detail: 'MMC (2n) present in nucellus of ovule. Large, dense cell with prominent nucleus.', icon: Icons.circle),
      BioStep(title: 'Meiosis I', detail: 'MMC undergoes Meiosis I → 2 haploid (n) cells called dyad.', icon: Icons.call_split),
      BioStep(title: 'Meiosis II', detail: 'Both cells divide → 4 megaspores (n) arranged linearly = linear tetrad.', icon: Icons.call_split),
      BioStep(title: 'Degeneration', detail: '3 megaspores (micropylar end) degenerate. 1 chalazal megaspore survives = Functional Megaspore.', icon: Icons.delete_outline),
      BioStep(title: 'Mitosis ×1', detail: 'Functional megaspore undergoes mitosis → 2 nuclei. Vacuole enlarges.', icon: Icons.add_circle_outline),
      BioStep(title: 'Mitosis ×2', detail: '2nd mitosis → 4 nuclei. 2 move to each pole.', icon: Icons.add_circle_outline),
      BioStep(title: 'Mitosis ×3', detail: '3rd mitosis → 8 nuclei. 3 at micropylar pole, 3 at chalazal, 2 polar nuclei migrate to centre.', icon: Icons.add_circle_outline),
      BioStep(title: '7-Celled Embryo Sac', detail: 'Cell walls form: 3 Antipodals (chalazal), 2 Synergids + 1 Egg cell (micropylar), 1 Central cell with 2 polar nuclei.', icon: Icons.check_circle),
    ],
  ),

  BioProcess(
    id: 'double_fertilization',
    title: 'Pollen-Pistil Interaction & Double Fertilization',
    chapter: 'Sexual Reproduction in Flowering Plants',
    classLevel: 12,
    emoji: '🌺',
    color: _repro,
    description: 'The unique process in angiosperms where two male gametes fuse with different female cells — one to form zygote, another to form endosperm.',
    keyPoints: [
      'Pollen tube germinates from compatible pollen on stigma',
      'Chemotropic growth of pollen tube through style',
      'Enters ovule through micropyle (porogamy)',
      '2 male gametes released into embryo sac',
      'Syngamy: Gamete + Egg → Zygote (2n)',
      'Triple fusion: Gamete + 2 Polar nuclei → PEN (3n) → Endosperm',
      'First described by Nawaschin (1898)',
    ],
    steps: [
      BioStep(title: 'Pollen Lands on Stigma', detail: 'Compatible pollen grain (mature 3-celled) lands on receptive stigma. Recognition via proteins (self-incompatibility system).', icon: Icons.fiber_manual_record),
      BioStep(title: 'Pollen Germination', detail: 'Pollen absorbs water/nutrients from stigma. Pollen tube emerges from germ pore.', icon: Icons.trending_up),
      BioStep(title: 'Tube Growth', detail: 'Pollen tube grows through transmitting tissue of style, guided chemotropically by calcium gradient.', icon: Icons.arrow_forward),
      BioStep(title: 'Entry into Ovule', detail: 'Pollen tube enters embryo sac through micropyle. Synergids degenerate to guide tube.', icon: Icons.login),
      BioStep(title: '2 Male Gametes Released', detail: 'Pollen tube bursts near egg apparatus. 2 male gametes (n) released into embryo sac.', icon: Icons.apps),
      BioStep(title: 'Syngamy (1st Fertilisation)', detail: 'Male gamete 1 + Egg cell (n+n) → Zygote (2n). This gives rise to embryo.', icon: Icons.merge),
      BioStep(title: 'Triple Fusion (2nd Fertilisation)', detail: 'Male gamete 2 + 2 Polar nuclei (n+2n) → Primary Endosperm Nucleus/PEN (3n). Gives rise to endosperm.', icon: Icons.merge_type),
      BioStep(title: 'Double Fertilisation Complete', detail: 'Both fertilisations = Double Fertilisation. Unique to angiosperms. Zygote → embryo; PEN → nutritive endosperm.', icon: Icons.check_circle),
    ],
  ),

  BioProcess(
    id: 'embryo_development',
    title: 'Post-Fertilisation: Embryo Development',
    chapter: 'Sexual Reproduction in Flowering Plants',
    classLevel: 12,
    emoji: '🌱',
    color: _repro,
    description: 'Development of the fertilised ovule into seed. Zygote → embryo, PEN → endosperm, integuments → seed coat, ovary → fruit.',
    keyPoints: [
      'Zygote undergoes first division asymmetrically',
      'Proembryo: octant stage → globular → heart → torpedo → mature',
      'Endosperm develops before embryo (nutritive function)',
      'Integuments → Testa and Tegmen (seed coats)',
      'Micropyle persists as small pore in seed coat',
      'Ovary wall → Pericarp (fruit wall)',
      'True fruit: only from ovary; False fruit: from other floral parts',
    ],
    steps: [
      BioStep(title: 'Zygote (2n)', detail: 'Zygote rests briefly. Polar nucleus at micropylar end, vacuole at chalazal. Then undergoes asymmetric division.', icon: Icons.circle),
      BioStep(title: 'Proembryo', detail: 'Zygote divides → small apical cell (embryo) + large basal cell (suspensor). Suspensor anchors embryo, provides nutrition.', icon: Icons.view_agenda),
      BioStep(title: 'Octant Stage', detail: 'Apical cell divides 3 times → 8 cells (octant). Basal cell → suspensor (5-10 cells); uppermost = hypophysis.', icon: Icons.grid_on),
      BioStep(title: 'Globular Embryo', detail: 'Further divisions form spherical mass. Protoderm (outer) differentiates first.', icon: Icons.radio_button_unchecked),
      BioStep(title: 'Heart-shaped Embryo', detail: 'Cotyledon primordia develop → heart shape. Procambium (future vasculature) visible.', icon: Icons.favorite_border),
      BioStep(title: 'Torpedo / Mature Embryo', detail: 'Cotyledons elongate. Plumule (shoot tip) and radicle (root tip) visible. Embryo axis = hypocotyl.', icon: Icons.arrow_upward),
      BioStep(title: 'Endosperm Development', detail: 'PEN (3n) divides repeatedly → endosperm (nutritive tissue). Nuclear type → cellular in monocots.', icon: Icons.grain),
      BioStep(title: 'Seed & Fruit', detail: 'Integuments → seed coats. Ovule → seed. Ovary → fruit (pericarp). Seed = mature ovule with stored food for germination.', icon: Icons.eco),
    ],
  ),

  // ── Human Reproduction ────────────────────────────────────────────────────
  BioProcess(
    id: 'spermatogenesis',
    title: 'Spermatogenesis',
    chapter: 'Human Reproduction',
    classLevel: 12,
    emoji: '🔬',
    color: _repro,
    description: 'Formation of spermatozoa from spermatogonial cells in the seminiferous tubules of testis. Requires 74 days in humans.',
    keyPoints: [
      'Occurs in seminiferous tubules at 34°C (below body temp)',
      'Sertoli cells provide nutrition (blood-testis barrier)',
      'Leydig cells secrete testosterone',
      'Spermatogonia (2n) → Spermatozoa (n)',
      'Spermiogenesis: spermatid → sperm (loss of cytoplasm, tail formation)',
      'Spermiation: release of mature sperm into lumen',
      'FSH stimulates Sertoli; LH stimulates Leydig cells',
    ],
    steps: [
      BioStep(title: 'Spermatogonia (2n)', detail: 'Germinal epithelial cells in seminiferous tubules. Type A: stem cells (self-renewing). Type B: committed to differentiation.', icon: Icons.circle),
      BioStep(title: 'Mitosis → Growth', detail: 'Type B spermatogonia multiply by mitosis. Cells enlarge → Primary Spermatocytes (2n). DNA replication occurs.', icon: Icons.add_circle),
      BioStep(title: 'Meiosis I', detail: 'Primary spermatocyte (2n) → 2 Secondary Spermatocytes (n). Each has 23 chromosomes (as dyads). Takes ~24 days.', icon: Icons.call_split),
      BioStep(title: 'Meiosis II', detail: 'Each Secondary Spermatocyte → 2 Spermatids (n, 23 chromosomes). Total 4 spermatids from 1 primary spermatocyte.', icon: Icons.call_split),
      BioStep(title: 'Spermiogenesis', detail: 'Spermatid (round) undergoes metamorphosis → Spermatozoon. Acrosome from Golgi, tail from centriole, mitochondria form midpiece, cytoplasm shed.', icon: Icons.transform),
      BioStep(title: 'Spermiation', detail: 'Mature spermatozoa released from Sertoli cells into lumen of seminiferous tubule. Transported to epididymis for maturation (~21 days).', icon: Icons.arrow_forward),
    ],
  ),

  BioProcess(
    id: 'oogenesis',
    title: 'Oogenesis',
    chapter: 'Human Reproduction',
    classLevel: 12,
    emoji: '🥚',
    color: _repro,
    description: 'Formation of mature ovum from oogonia in the ovary. Begins during fetal life; completed only after fertilisation. Highly unequal division produces one large ovum and polar bodies.',
    keyPoints: [
      'Oogonia (2n) multiply in fetal ovary by mitosis',
      'Primary oocytes arrested in Prophase I (birth–puberty)',
      'One primary oocyte matures each cycle after puberty',
      'Meiosis I → Secondary oocyte (n) + 1st Polar Body',
      'Secondary oocyte arrested at Metaphase II',
      'Meiosis II completed only on fertilisation',
      'Unequal cytokinesis: one large cell + small polar bodies',
    ],
    steps: [
      BioStep(title: 'Oogonia (Fetal Life)', detail: 'Oogonial cells (2n) in fetal ovary multiply by mitosis. ~7 million at 20 weeks gestation. Reduce to ~2 million at birth.', icon: Icons.circle),
      BioStep(title: 'Primary Oocyte Formation', detail: 'Oogonia → Primary Oocytes (2n). Enter Prophase I of meiosis → ARRESTED here until puberty. Each enclosed in primordial follicle.', icon: Icons.pause_circle),
      BioStep(title: 'Follicle Maturation (Puberty)', detail: 'FSH stimulates primordial follicle → Primary → Secondary → Graafian follicle. Primary oocyte resumes meiosis I.', icon: Icons.trending_up),
      BioStep(title: 'Meiosis I Completion', detail: 'Just before ovulation: Primary oocyte (2n) completes Meiosis I → Secondary oocyte (n) + 1st Polar Body (n). Unequal division.', icon: Icons.call_split),
      BioStep(title: 'Ovulation', detail: 'Graafian follicle ruptures → Secondary oocyte released (ovulation, day 14). Secondary oocyte arrested at Metaphase II.', icon: Icons.output),
      BioStep(title: 'Meiosis II (On Fertilisation)', detail: 'If sperm penetrates, Meiosis II resumes → Ootid (n) + 2nd Polar Body (n). 1st polar body may divide → 3 polar bodies total.', icon: Icons.call_split),
      BioStep(title: 'Mature Ovum', detail: 'Ootid matures → Ovum (n). Only 1 large functional cell produced from 1 primary oocyte. Polar bodies degenerate.', icon: Icons.check_circle),
    ],
  ),

  BioProcess(
    id: 'placenta',
    title: 'Placenta Formation',
    chapter: 'Human Reproduction',
    classLevel: 12,
    emoji: '🫀',
    color: _repro,
    description: 'The placenta is a temporary organ formed by interlocking of uterine and embryonic tissues. It connects mother and fetus for nutrient/gas/waste exchange.',
    keyPoints: [
      'Implantation: blastocyst embeds in endometrium (6–7 days)',
      'Trophoblast → cytotrophoblast + syncytiotrophoblast',
      'Chorionic villi project into maternal blood sinuses',
      'Haemochorial placenta in humans (maternal blood contacts villi)',
      'Functions: nutrition, respiration, excretion, hormone secretion',
      'Secretes hCG (maintains corpus luteum), oestrogen, progesterone, hPL',
      'Acts as barrier but not absolute (drugs, pathogens can cross)',
    ],
    steps: [
      BioStep(title: 'Blastocyst Formation', detail: 'Zygote → morula → blastocyst by day 5-6. Blastocyst: outer trophoblast + inner cell mass (embryoblast).', icon: Icons.circle),
      BioStep(title: 'Implantation', detail: 'Blastocyst reaches uterus. Zona pellucida lost (hatching). Trophoblast adheres to endometrium (~day 7). Site usually posterior wall of uterus.', icon: Icons.anchor),
      BioStep(title: 'Trophoblast Invasion', detail: 'Syncytiotrophoblast invades endometrial stroma. Enzymes digest maternal tissue. Cytotrophoblast proliferates.', icon: Icons.arrow_outward),
      BioStep(title: 'Chorionic Villi', detail: 'Trophoblast cells form finger-like projections = chorionic villi. Core: fetal capillaries. Covered by trophoblast cells.', icon: Icons.hub),
      BioStep(title: 'Maternal Blood Sinuses', detail: 'Syncytiotrophoblast erodes maternal blood vessels. Maternal blood fills intervillous space around villi.', icon: Icons.water_drop),
      BioStep(title: 'Exchange Barrier', detail: 'Exchange occurs across: syncytiotrophoblast, cytotrophoblast, fetal capillary wall. O₂, glucose → fetus; CO₂, urea → mother.', icon: Icons.swap_horiz),
      BioStep(title: 'Hormone Secretion', detail: 'Placenta secretes: hCG (early, maintains corpus luteum), oestrogen, progesterone (maintains pregnancy), hPL (lactogenic, insulin-antagonist).', icon: Icons.science),
      BioStep(title: 'Mature Placenta', detail: 'Discoid shape, ~500g. Expelled as afterbirth ~30 min post-delivery. Umbilical cord: 2 umbilical arteries + 1 umbilical vein.', icon: Icons.check_circle),
    ],
  ),

  // ── Molecular Basis of Inheritance ───────────────────────────────────────
  BioProcess(
    id: 'dna_double_helix',
    title: 'Double Helical Structure of DNA',
    chapter: 'Molecular Basis of Inheritance',
    classLevel: 12,
    emoji: '🧬',
    color: _mol,
    description: 'Watson and Crick (1953) proposed the B-DNA double helix model based on X-ray crystallography data of Franklin & Wilkins and Chargaff\'s rules.',
    keyPoints: [
      'Two antiparallel polynucleotide strands: 5\'→3\' and 3\'→5\'',
      'Right-handed double helix',
      'A=T (2 H-bonds), G≡C (3 H-bonds) — Chargaff\'s rules: A=T, G=C',
      'Sugar-phosphate backbone on outside; nitrogenous bases inside',
      'Pitch = 3.4 nm; Rise per base pair = 0.34 nm; 10 bp per turn',
      'Diameter = 2 nm',
      'Purines: Adenine, Guanine (2 rings); Pyrimidines: Thymine, Cytosine (1 ring)',
    ],
    steps: [
      BioStep(title: 'Nucleotide Monomer', detail: 'Each nucleotide: Deoxyribose sugar (5C) + Phosphate group + Nitrogenous base. Bases: A,T,G,C (purines: A,G; pyrimidines: T,C).', icon: Icons.circle),
      BioStep(title: 'Polynucleotide Chain', detail: '3\'–5\' phosphodiester bonds link nucleotides. Sugar of one nucleotide + phosphate of next. Chain has free 5\'-OH at one end and 3\'-OH at other.', icon: Icons.link),
      BioStep(title: 'Antiparallel Strands', detail: 'Two strands oriented antiparallel: one 5\'→3\', other 3\'→5\'. This allows optimal base stacking.', icon: Icons.swap_vert),
      BioStep(title: 'Complementary Base Pairing', detail: 'A pairs with T (2 hydrogen bonds). G pairs with C (3 hydrogen bonds). Purine always pairs with pyrimidine → constant 2 nm width.', icon: Icons.compare),
      BioStep(title: 'Right-Handed Helix', detail: 'Two strands wind around common axis in right-handed manner. Major groove (wider) and minor groove (narrower) alternate.', icon: Icons.rotate_right),
      BioStep(title: 'Helix Parameters', detail: 'One complete helical turn = 10 bp. Pitch (height per turn) = 3.4 nm. Rise per base pair = 0.34 nm. Diameter = 2 nm.', icon: Icons.straighten),
      BioStep(title: 'Stabilising Forces', detail: 'H-bonds between bases (specific pairing). Hydrophobic base-stacking interactions (major stabiliser). Negatively charged backbone repels but neutralised by histones.', icon: Icons.security),
    ],
  ),

  BioProcess(
    id: 'griffith',
    title: 'Griffith\'s Experiment',
    chapter: 'Molecular Basis of Inheritance',
    classLevel: 12,
    emoji: '🐭',
    color: _mol,
    description: 'Frederick Griffith (1928) demonstrated genetic transformation in Streptococcus pneumoniae, showing that hereditary information could be transferred between bacteria.',
    keyPoints: [
      'Two strains: S (smooth, virulent, capsule) and R (rough, non-virulent)',
      'Capsule in S-strain prevents phagocytosis → virulent',
      'Live R-strain: non-lethal. Live S-strain: lethal',
      'Heat-killed S-strain: non-lethal (proteins denatured)',
      'Heat-killed S + Live R: LETHAL → live S-type bacteria recovered',
      'Transforming principle: some stable chemical from dead S transforms R',
      'Nature of transforming principle not identified by Griffith',
    ],
    steps: [
      BioStep(title: 'S-strain (Virulent)', detail: 'Smooth strain has polysaccharide capsule. Resists phagocytosis. Injection into mouse → DEATH. Live S bacteria recovered from dead mouse.', icon: Icons.dangerous),
      BioStep(title: 'R-strain (Avirulent)', detail: 'Rough strain lacks capsule. Easily phagocytosed. Injection into mouse → MOUSE SURVIVES. R strain isolated from blood.', icon: Icons.check_circle_outline),
      BioStep(title: 'Heat-killed S-strain', detail: 'S-strain boiled (proteins denatured, cells dead). Injection into mouse → MOUSE SURVIVES. Heat kills virulence but something stable remains.', icon: Icons.local_fire_department),
      BioStep(title: 'Heat-killed S + Live R', detail: 'Mix of heat-killed S + live R injected into mouse → MOUSE DIES. Live S-type bacteria recovered from dead mouse!', icon: Icons.warning),
      BioStep(title: 'Transformation Occurs', detail: 'Some stable "transforming principle" from dead S was transferred to live R cells, converting them to S-type permanently.', icon: Icons.transform),
      BioStep(title: 'Griffith\'s Conclusion', detail: 'A biochemical substance from dead S-cells transformed R-cells into virulent S-type. This was heritable and stable. Substance NOT identified (Griffith didn\'t know it was DNA).', icon: Icons.science),
    ],
  ),

  BioProcess(
    id: 'hershey_chase',
    title: 'Hershey-Chase Experiment',
    chapter: 'Molecular Basis of Inheritance',
    classLevel: 12,
    emoji: '🦠',
    color: _mol,
    description: 'Alfred Hershey and Martha Chase (1952) used radioactive isotopes to prove that DNA, not protein, is the genetic material injected by T2 bacteriophage into bacteria.',
    keyPoints: [
      'T2 phage: protein coat (capsid) + DNA inside',
      '35S labels protein (sulfur in amino acids, not in DNA)',
      '32P labels DNA (phosphorus in DNA, not in protein)',
      'After infection: 35S in supernatant (outside bacteria)',
      '32P in pellet (inside bacteria = injected material = DNA)',
      'Progeny phages contained 32P (DNA transmitted)',
      'Conclusively proved: DNA is the genetic material',
    ],
    steps: [
      BioStep(title: 'Batch 1: 35S-labelled Phage', detail: 'T2 phages grown on bacteria in medium with ³⁵S. Only proteins incorporate ³⁵S (amino acids contain S, DNA does not). ³⁵S labels the protein coat.', icon: Icons.science),
      BioStep(title: 'Batch 2: 32P-labelled Phage', detail: 'T2 phages grown with ³²P. Only DNA incorporates ³²P (phosphate in DNA backbone). Protein coat not labelled.', icon: Icons.science),
      BioStep(title: 'Phage Infection', detail: 'Both batches separately infect E. coli. T2 phage injects its genetic material; protein coat stays outside (ghost).', icon: Icons.login),
      BioStep(title: 'Blender Agitation', detail: 'After infection, mixture agitated in blender to separate phage coats (ghosts) from bacteria. Then centrifuged.', icon: Icons.science),
      BioStep(title: 'Centrifugation Results', detail: 'Bacteria (heavy) → pellet. Phage coats (light) → supernatant. ³⁵S: mostly in SUPERNATANT (protein coats stayed outside). ³²P: mostly in PELLET (DNA injected into bacteria).', icon: Icons.filter_list),
      BioStep(title: 'Progeny Phage Analysis', detail: 'New phages produced inside bacteria contained ³²P (DNA passed to next generation). ³⁵S NOT in progeny (protein coat not inherited).', icon: Icons.content_copy),
      BioStep(title: 'Conclusion', detail: 'DNA, not protein, is injected into bacteria and transmitted to progeny. DNA = genetic material of T2 bacteriophage.', icon: Icons.check_circle),
    ],
  ),

  BioProcess(
    id: 'meselson_stahl',
    title: 'Meselson and Stahl Experiment',
    chapter: 'Molecular Basis of Inheritance',
    classLevel: 12,
    emoji: '⚗️',
    color: _mol,
    description: 'Meselson and Stahl (1958) proved semi-conservative replication of DNA using ¹⁵N/¹⁴N density labelling and CsCl density gradient centrifugation — "the most beautiful experiment in biology".',
    keyPoints: [
      '¹⁵N (heavy) vs ¹⁴N (light) isotopes used to label DNA',
      'CsCl density gradient centrifugation separates by density',
      'Generation 0 (¹⁵N only): one heavy band',
      'Generation 1 (in ¹⁴N): one HYBRID band (intermediate density)',
      'Generation 2: two bands — hybrid + light (1:1 ratio)',
      'Consistent ONLY with semi-conservative replication',
      'Each daughter DNA = one old strand + one new strand',
    ],
    steps: [
      BioStep(title: 'Generation 0 (Heavy DNA)', detail: 'E. coli grown in ¹⁵NH₄Cl medium for many generations. All DNA contains ¹⁵N in both strands = heavy DNA. One dense band in CsCl gradient.', icon: Icons.tune),
      BioStep(title: 'Transfer to ¹⁴N Medium', detail: 'Bacteria transferred to normal ¹⁴N medium. DNA sampled at each generation. New nucleotides will contain ¹⁴N only.', icon: Icons.swap_horiz),
      BioStep(title: 'Generation 1 Analysis', detail: 'After 1 generation in ¹⁴N: DNA shows ONE band at INTERMEDIATE density (hybrid). Both daughter DNAs are ¹⁵N-¹⁴N (one old + one new strand).', icon: Icons.horizontal_rule),
      BioStep(title: 'Hybrid Band = Semi-Conservative', detail: 'This intermediate band proves each daughter molecule has one parental (¹⁵N) strand + one new (¹⁴N) strand. Rules out conservative replication.', icon: Icons.merge),
      BioStep(title: 'Generation 2 Analysis', detail: 'After 2nd generation: TWO bands — hybrid (¹⁵N-¹⁴N) and light (¹⁴N-¹⁴N) in 1:1 ratio. Rules out dispersive replication.', icon: Icons.looks_two),
      BioStep(title: 'Conclusion', detail: 'Results match ONLY semi-conservative model: each new DNA retains one original strand. Watson-Crick model vindicated. Completely rules out conservative and dispersive models.', icon: Icons.check_circle),
    ],
  ),

  BioProcess(
    id: 'replication',
    title: 'DNA Replication',
    chapter: 'Molecular Basis of Inheritance',
    classLevel: 12,
    emoji: '🔁',
    color: _mol,
    description: 'Semi-conservative replication of DNA during S phase of cell cycle. Bidirectional replication from origins (ori) using multiple enzymes.',
    keyPoints: [
      'Semi-conservative: each daughter has one old + one new strand',
      'Begins at origin of replication (ori-C in E. coli)',
      'Helicase unwinds; SSB proteins stabilise; Topoisomerase relieves tension',
      'Primase adds RNA primer (DNA Pol cannot initiate)',
      'DNA Pol III: main replicating enzyme (5\'→3\' synthesis)',
      'Leading strand: continuous; Lagging: Okazaki fragments (discontinuous)',
      'DNA Pol I removes primers; DNA Ligase joins fragments',
    ],
    steps: [
      BioStep(title: 'Initiation at Origin', detail: 'Initiator proteins recognise ori sequence. Replication bubble forms. Two replication forks move bidirectionally.', icon: Icons.start),
      BioStep(title: 'Unwinding (Helicase)', detail: 'Helicase breaks H-bonds, separates DNA strands at replication fork. Topoisomerase II (Gyrase) cuts and religates DNA ahead to relieve supercoiling.', icon: Icons.lock_open),
      BioStep(title: 'Stabilisation (SSB)', detail: 'Single-strand binding proteins (SSBs) coat separated strands, preventing re-annealing and protecting from nucleases.', icon: Icons.security),
      BioStep(title: 'Primer Synthesis', detail: 'Primase (RNA polymerase) synthesises short RNA primer (5–15 nt) complementary to template. DNA Pol III needs free 3\'-OH to start.', icon: Icons.create),
      BioStep(title: 'Leading Strand Synthesis', detail: 'DNA Pol III synthesises continuously from RNA primer toward replication fork (5\'→3\'). Template read 3\'→5\'. One primer needed.', icon: Icons.arrow_forward),
      BioStep(title: 'Lagging Strand Synthesis', detail: 'Lagging strand synthesised away from fork in fragments (Okazaki fragments, 1000-2000 nt in prokaryotes). Multiple primers needed.', icon: Icons.arrow_back),
      BioStep(title: 'Gap Filling', detail: 'DNA Pol I (5\'→3\' exonuclease activity): removes RNA primers, fills gaps with DNA using adjacent 3\'-OH as primer.', icon: Icons.build),
      BioStep(title: 'Ligation', detail: 'DNA Ligase seals nicks between Okazaki fragments (joins 3\'-OH to 5\'-phosphate using ATP). Continuous daughter strands formed.', icon: Icons.link),
      BioStep(title: 'Termination', detail: 'Two replication forks meet at termination sequences (ter). Topoisomerase IV decatenates (separates) interlocked daughter chromosomes.', icon: Icons.stop),
    ],
  ),

  BioProcess(
    id: 'transcription',
    title: 'Transcription',
    chapter: 'Molecular Basis of Inheritance',
    classLevel: 12,
    emoji: '📝',
    color: _mol,
    description: 'Synthesis of RNA from DNA template. In eukaryotes: hnRNA → processed → mature mRNA. Three types: mRNA, tRNA, rRNA.',
    keyPoints: [
      'Template strand (antisense) read 3\'→5\'; RNA synthesised 5\'→3\'',
      'RNA Pol unwinds DNA ~17 bp at transcription bubble',
      'Promoter: TATA box (eukaryotes), -10 and -35 (prokaryotes)',
      'Prokaryotes: single RNA Pol; Eukaryotes: Pol I, II, III (mRNA by Pol II)',
      'Monocistronic mRNA in eukaryotes; polycistronic in prokaryotes',
      'Post-transcriptional: 5\' capping, 3\' polyadenylation, splicing of introns',
      'hnRNA → mRNA by splicing (spliceosomes remove introns)',
    ],
    steps: [
      BioStep(title: 'Promoter Recognition', detail: 'RNA Polymerase + σ (sigma) factor (prokaryotes) OR basal transcription factors (eukaryotes) recognise promoter. TATA box at -25 in eukaryotes.', icon: Icons.search),
      BioStep(title: 'Open Complex Formation', detail: 'RNA Pol unwinds ~17 bp of DNA = transcription bubble. Template strand (antisense, 3\'→5\') exposed for reading.', icon: Icons.lock_open),
      BioStep(title: 'Initiation', detail: 'First ribonucleotide added to template. RNA Pol does NOT need primer. Synthesis begins at +1 (start site). Short transcripts initially made (abortive initiation).', icon: Icons.play_arrow),
      BioStep(title: 'Elongation', detail: 'RNA Pol moves 3\'→5\' along template, synthesising RNA 5\'→3\'. Ribonucleoside triphosphates (NTPs) added. Complementary to template (U instead of T).', icon: Icons.trending_up),
      BioStep(title: 'Post-transcriptional (Eukaryotes)', detail: '5\' capping: 7-methyl guanosine cap added (protects from degradation, aids translation initiation). Occurs co-transcriptionally.', icon: Icons.add_box),
      BioStep(title: 'Polyadenylation', detail: 'AAUAAA signal → cleavage 10-30 nt downstream. 50-250 adenylate residues (poly-A tail) added by poly-A polymerase. Protects from 3\' degradation.', icon: Icons.format_list_bulleted),
      BioStep(title: 'Splicing', detail: 'Spliceosome (snRNPs) removes introns from hnRNA. Exons joined. Alternative splicing → different proteins from same gene. ~95% human genes alternatively spliced.', icon: Icons.content_cut),
      BioStep(title: 'Mature mRNA Export', detail: 'Processed mRNA (capped, polyadenylated, spliced) exported through nuclear pores to cytoplasm for translation.', icon: Icons.output),
    ],
  ),

  BioProcess(
    id: 'translation',
    title: 'Translation',
    chapter: 'Molecular Basis of Inheritance',
    classLevel: 12,
    emoji: '🏭',
    color: _mol,
    description: 'Decoding of mRNA sequence into amino acid sequence (polypeptide). Occurs at ribosomes in cytoplasm. Requires mRNA, tRNA, rRNA, amino acids, and factors.',
    keyPoints: [
      'Genetic code: triplet codons (64 total: 61 sense + 3 stop)',
      'Code is degenerate (multiple codons per AA), non-overlapping, universal',
      'Ribosome has P site (peptidyl) and A site (aminoacyl) and E site (exit)',
      'Start codon: AUG (codes Met); Stop: UAA, UAG, UGA',
      'Aminoacyl-tRNA synthetase charges tRNA (2nd genetic code)',
      'Peptide bond by peptidyl transferase (ribozyme activity of 23S rRNA)',
      'Growing chain N→C terminus; mRNA read 5\'→3\'',
    ],
    steps: [
      BioStep(title: 'Charging tRNA', detail: 'Aminoacyl-tRNA synthetase (20 types) catalyses: AA + tRNA + ATP → AA-tRNA + AMP + PPi. Each tRNA charged with specific amino acid.', icon: Icons.charging_station),
      BioStep(title: 'Initiation (Prokaryotes)', detail: 'Small (30S) subunit + mRNA at Shine-Dalgarno sequence. fMet-tRNA binds AUG at P site. Large (50S) subunit joins. 70S initiation complex formed.', icon: Icons.start),
      BioStep(title: 'Initiation (Eukaryotes)', detail: '43S complex (40S + Met-tRNA + eIF2-GTP) scans from 5\' cap to AUG (Kozak sequence). 60S joins → 80S initiation complex.', icon: Icons.start),
      BioStep(title: 'Elongation: A site', detail: 'Aminoacyl-tRNA (EF-Tu·GTP in prokaryotes) delivers correct tRNA to A site. Codon-anticodon pairing verified. GTP hydrolysed.', icon: Icons.add_circle),
      BioStep(title: 'Peptide Bond Formation', detail: 'Peptidyl transferase (23S rRNA = ribozyme): transfers growing peptide chain from P-site tRNA to A-site amino acid. Peptide bond formed.', icon: Icons.link),
      BioStep(title: 'Translocation', detail: 'EF-G·GTP drives translocation: ribosome moves 3 nt (1 codon) in 5\'→3\' direction. Old A-site tRNA → P site → E site → released. mRNA advances.', icon: Icons.arrow_forward),
      BioStep(title: 'Termination', detail: 'Stop codon (UAA/UAG/UGA) in A site. Release factor binds (no tRNA for stop). Peptide released. Ribosome dissociates. mRNA released.', icon: Icons.stop),
      BioStep(title: 'Post-translational Modification', detail: 'Folding (chaperones), signal peptide cleavage, glycosylation, phosphorylation, disulfide bonds, targeting to correct compartment.', icon: Icons.build),
    ],
  ),

  BioProcess(
    id: 'lac_operon',
    title: 'Lac Operon',
    chapter: 'Molecular Basis of Inheritance',
    classLevel: 12,
    emoji: '🔬',
    color: _mol,
    description: 'Jacob and Monod\'s (1961) model of gene regulation in E. coli. The lac operon controls metabolism of lactose through negative regulation by a repressor.',
    keyPoints: [
      'Operon: Promoter + Operator + Structural genes (lacZ, lacY, lacA)',
      'lacI gene (constitutive) produces lac repressor protein',
      'Repressor binds operator → blocks RNA Pol → genes OFF',
      'Inducer: allolactose (metabolite of lactose) inactivates repressor',
      'Inducer + Repressor → conformational change → cannot bind operator',
      'Positive regulation: CRP (CAP)-cAMP complex enhances transcription (catabolite repression)',
      'Glucose present → low cAMP → weak transcription even with lactose',
    ],
    steps: [
      BioStep(title: 'Genes of Lac Operon', detail: 'lacI: Repressor gene (always ON). Promoter (p): RNA Pol binding site. Operator (o): Repressor binding site. lacZ: β-galactosidase. lacY: Permease. lacA: Transacetylase.', icon: Icons.description),
      BioStep(title: 'No Lactose — Genes OFF', detail: 'lacI constitutively produces Repressor protein. Active repressor binds operator. RNA Pol cannot pass operator → No transcription of lacZ, Y, A.', icon: Icons.lock),
      BioStep(title: 'Lactose Added', detail: 'Some lactose enters cell via few permease molecules. β-galactosidase converts lactose → allolactose (isomer). Allolactose = inducer.', icon: Icons.add_circle),
      BioStep(title: 'Inducer Inactivates Repressor', detail: 'Allolactose binds lac repressor → allosteric conformational change. Repressor cannot bind operator (low affinity).', icon: Icons.lock_open),
      BioStep(title: 'Transcription ON', detail: 'RNA Pol binds promoter freely → transcribes polycistronic mRNA (lacZ + lacY + lacA). All three proteins produced.', icon: Icons.play_arrow),
      BioStep(title: 'Lactose Metabolised', detail: 'β-galactosidase breaks down lactose. As lactose falls, allolactose levels fall. Repressor re-activates → binds operator → genes switch OFF again.', icon: Icons.remove_circle),
      BioStep(title: 'Catabolite Repression', detail: 'When glucose present: adenylyl cyclase inhibited → low cAMP. CRP-cAMP complex not formed. CRP required for strong transcription from lac promoter.', icon: Icons.trending_down),
    ],
  ),

  BioProcess(
    id: 'rdna',
    title: 'Recombinant DNA Technology',
    chapter: 'Biotechnology: Principles and Processes',
    classLevel: 12,
    emoji: '🧪',
    color: _biotech,
    description: 'Technology to isolate, manipulate, and replicate DNA from different sources by combining them in vitro using restriction enzymes, vectors, and host organisms.',
    keyPoints: [
      'Restriction endonucleases: cut DNA at specific palindromic sequences (Type II)',
      'EcoRI cuts at G↓AATTC; creates sticky ends (4-nt overhangs)',
      'Vectors: plasmids, bacteriophage λ, cosmids, BAC, YAC',
      'Selectable markers: antibiotic resistance genes (ampR, tetR)',
      'Transformation: CaCl₂ treatment makes bacteria competent',
      'Screening: colony hybridisation, blue-white selection (lacZ)',
      'Expression vector: promoter + RBS + MCS + terminator',
    ],
    steps: [
      BioStep(title: 'Identify Gene of Interest', detail: 'Locate target gene in donor organism genome. Can use cDNA (from mRNA via reverse transcriptase) to avoid introns in eukaryotic genes.', icon: Icons.search),
      BioStep(title: 'Restriction Digestion', detail: 'Same restriction enzyme cuts both donor DNA and vector at palindromic sites. Creates compatible sticky ends (complementary overhangs) for ligation.', icon: Icons.content_cut),
      BioStep(title: 'Vector Preparation', detail: 'Plasmid vector cut at MCS (Multiple Cloning Site) within lacZ gene. Vector linearised. Dephosphorylated with alkaline phosphatase to prevent self-ligation.', icon: Icons.settings),
      BioStep(title: 'Ligation', detail: 'DNA ligase joins insert + vector via complementary sticky ends using ATP. Recombinant plasmid formed. Ligation at 16°C overnight.', icon: Icons.link),
      BioStep(title: 'Transformation', detail: 'Recombinant DNA introduced into E. coli (competent cells made with CaCl₂ or electroporation). Heat shock at 42°C: plasmid enters.', icon: Icons.input),
      BioStep(title: 'Selection of Recombinants', detail: 'Plate on ampicillin + X-gal. Cells with plasmid: Amp-resistant (white colonies if insert disrupts lacZ = recombinant; blue = non-recombinant).', icon: Icons.filter_list),
      BioStep(title: 'Confirmation & Expression', detail: 'Colony PCR or restriction analysis confirms insert. Subclone into expression vector with strong promoter. Induce expression. Protein production and purification.', icon: Icons.check_circle),
    ],
  ),

  BioProcess(
    id: 'gel_electrophoresis',
    title: 'Gel Electrophoresis',
    chapter: 'Biotechnology: Principles and Processes',
    classLevel: 12,
    emoji: '⚡',
    color: _biotech,
    description: 'Technique to separate DNA/RNA/proteins by size and charge through a porous gel matrix under electric field. Standard tool in molecular biology.',
    keyPoints: [
      'DNA is negatively charged (phosphate backbone) → moves toward anode (+)',
      'Agarose gel: 0.5–2% for DNA; higher% separates smaller fragments',
      'Ethidium bromide (EtBr) intercalates DNA; fluorescent under UV',
      'DNA ladder (size marker) used for molecular weight determination',
      'Smaller fragments migrate faster (less resistance through gel pores)',
      'SDS-PAGE for proteins: SDS denatures + charges proteins uniformly',
      'Used in RFLP, Southern blotting, western blotting, PCR analysis',
    ],
    steps: [
      BioStep(title: 'Gel Preparation', detail: 'Agarose dissolved in TAE/TBE buffer, boiled, poured into casting tray with comb. Allow to solidify at room temperature (~30 min).', icon: Icons.layers),
      BioStep(title: 'Sample Preparation', detail: 'DNA samples mixed with loading dye (glycerol for density, bromophenol blue tracking dye). Comb removed, gel placed in electrophoresis tank with buffer.', icon: Icons.color_lens),
      BioStep(title: 'Loading', detail: 'Samples (including DNA ladder/marker) pipetted into wells. Ladder has fragments of known size for comparison.', icon: Icons.download),
      BioStep(title: 'Electrophoresis', detail: 'Electric current applied (100V, 30-45 min). Negatively charged DNA migrates toward positive electrode (red/anode). Smaller fragments travel farther.', icon: Icons.flash_on),
      BioStep(title: 'Staining', detail: 'Gel stained with ethidium bromide (carcinogenic but sensitive) or SYBR Safe/GelRed (safer). EtBr intercalates between base pairs.', icon: Icons.science),
      BioStep(title: 'Visualisation', detail: 'Gel placed on UV transilluminator. EtBr-DNA fluoresces orange-red. Bands photographed. Compare with ladder to determine fragment sizes.', icon: Icons.wb_sunny),
      BioStep(title: 'Interpretation', detail: 'Each band = DNA of one size. Band brightness ∝ amount of DNA. Elution from gel: bands cut out, DNA recovered by electroelution or freeze-squeeze for further use.', icon: Icons.analytics),
    ],
  ),

  BioProcess(
    id: 'pcr',
    title: 'Polymerase Chain Reaction (PCR)',
    chapter: 'Biotechnology: Principles and Processes',
    classLevel: 12,
    emoji: '🔄',
    color: _biotech,
    description: 'In vitro method to amplify specific DNA sequences exponentially (2ⁿ copies after n cycles) using thermostable Taq DNA polymerase. Developed by Kary Mullis (1983, Nobel Prize 1993).',
    keyPoints: [
      'Three steps per cycle: Denaturation (94-95°C), Annealing (50-65°C), Extension (72°C)',
      'Taq polymerase: thermostable from Thermus aquaticus (hot spring bacteria)',
      'Two specific primers (18-25 nt) flank the target sequence',
      'Exponential amplification: 2ⁿ copies after n cycles (~30-35 cycles)',
      '30 cycles → ~1 billion copies of target from single molecule',
      'Applications: forensics, diagnostics (COVID-19), prenatal diagnosis, cloning',
      'RT-PCR: RNA template first converted to cDNA by reverse transcriptase',
    ],
    steps: [
      BioStep(title: 'Components', detail: 'Reaction mix: Template DNA, Forward primer, Reverse primer, dNTPs (dATP, dTTP, dGTP, dCTP), Taq polymerase, MgCl₂ buffer, Thermocycler.', icon: Icons.settings),
      BioStep(title: 'Denaturation (94-95°C, 30s)', detail: 'High temperature breaks hydrogen bonds between complementary strands. Double-stranded DNA → two single strands. Template exposed for primer binding.', icon: Icons.local_fire_department),
      BioStep(title: 'Annealing (50-65°C, 30s)', detail: 'Temperature lowered to allow primers to bind to complementary sequences on template strands. Short specific oligonucleotides anneal at 3\' end of target.', icon: Icons.link),
      BioStep(title: 'Extension (72°C, 1 min/kb)', detail: 'Taq polymerase extends from 3\' end of primers. Optimal at 72°C. New strand synthesised 5\'→3\'. Products of variable length initially.', icon: Icons.arrow_forward),
      BioStep(title: 'Cycle 1 Results', detail: 'After 1 cycle: 2 copies per template (mixed-length products = "long products"). These serve as templates for next cycle.', icon: Icons.looks_one),
      BioStep(title: 'Exponential Amplification', detail: 'Cycle 3+: "Short products" (precise target size) accumulate exponentially. After 30 cycles: 2³⁰ ≈ 1 billion copies of the exact target sequence.', icon: Icons.trending_up),
      BioStep(title: 'Analysis', detail: 'PCR products verified on agarose gel (expected band size). Further: sequencing, restriction analysis, cloning, direct use as diagnostic marker.', icon: Icons.analytics),
    ],
  ),

  BioProcess(
    id: 'micropropagation',
    title: 'Micropropagation (Plant Tissue Culture)',
    chapter: 'Biotechnology and its Applications',
    classLevel: 12,
    emoji: '🌿',
    color: _biotech,
    description: 'In vitro vegetative propagation of plants from small explants on artificial nutrient media. Produces genetically identical plants (somaclones) rapidly and in large numbers.',
    keyPoints: [
      'Totipotency: each cell has potential to develop into complete plant',
      'Explant: any plant part used (meristem preferred — disease-free)',
      'Media: Murashige-Skoog (MS) — minerals, vitamins, sugar, agar, hormones',
      'Callus: undifferentiated mass formed (dedifferentiation)',
      'Shoot organogenesis: high cytokinin:auxin ratio',
      'Root organogenesis: high auxin:cytokinin ratio',
      'Somatic hybridisation: protoplast fusion between species',
    ],
    steps: [
      BioStep(title: 'Explant Selection', detail: 'Choose explant: meristem (shoot apical, axillary bud — disease-free, totipotent), leaf, root, anther. Disease-free parent plant essential.', icon: Icons.content_cut),
      BioStep(title: 'Surface Sterilisation', detail: 'Wash in detergent, rinse. 70% ethanol (brief), then sodium hypochlorite (5-10%) with Tween-20. Multiple sterile water rinses. All work in laminar flow hood (aseptic).', icon: Icons.cleaning_services),
      BioStep(title: 'Culture Initiation', detail: 'Explant placed on solid/liquid MS medium with appropriate hormones. Incubated at 25°C, 16h light/8h dark. Growth begins in 1-4 weeks.', icon: Icons.eco),
      BioStep(title: 'Callus Induction', detail: 'Balanced auxin + cytokinin → callus formation (friable mass of undifferentiated cells). Dedifferentiation. Cells divide rapidly.', icon: Icons.grain),
      BioStep(title: 'Organogenesis/Embryogenesis', detail: 'Altering hormone ratio induces redifferentiation. High cytokinin → shoot buds. High auxin → roots. OR: somatic embryogenesis (embryo-like structures directly).', icon: Icons.hub),
      BioStep(title: 'Shoot and Root Induction', detail: 'Micro-shoots transferred to rooting medium (IBA/NAA, no cytokinin). Roots develop in 2-3 weeks → complete plantlet.', icon: Icons.open_in_full),
      BioStep(title: 'Hardening', detail: 'Plantlets gradually acclimatised (higher light, lower humidity, sterile soil). Transferred from agar to moist soil mix. Covered with plastic for humidity.', icon: Icons.wb_sunny),
      BioStep(title: 'Field Transfer', detail: 'Hardened plants transferred to greenhouse then field. Thousands of identical plants produced from one explant. Applications: orchids, potato, banana, sugarcane.', icon: Icons.nature),
    ],
  ),

  // ════════════════════════════════ CLASS 11 ═══════════════════════════════

  // ── Plant Kingdom ──────────────────────────────────────────────────────────
  BioProcess(
    id: 'bryophyta_lifecycle',
    title: 'Life Cycle of Bryophyta',
    chapter: 'Plant Kingdom',
    classLevel: 11,
    emoji: '🌿',
    color: _plant,
    description: 'Bryophytes (mosses, liverworts, hornworts) show alternation of generations. The haploid gametophyte is the dominant, independent phase; diploid sporophyte is dependent.',
    keyPoints: [
      'Dominant phase: GAMETOPHYTE (n, green, photosynthetic, independent)',
      'Sporophyte (2n) is partially/fully dependent on gametophyte',
      'Require water for fertilisation (flagellated antherozoids)',
      'Archegonium (♀) flask-shaped; Antheridium (♂) club-shaped',
      'Capsule produces spores by meiosis (meiosis → spores)',
      'Spore → protonema → leafy gametophyte',
      'First land plants — evolutionary link between algae and vascular plants',
    ],
    steps: [
      BioStep(title: 'Spore (n)', detail: 'Haploid spore (n) produced by meiosis inside sporophyte capsule. Dispersed by wind. Resistant to desiccation. Germinates on moist substrate.', icon: Icons.grain),
      BioStep(title: 'Protonema', detail: 'Spore germinates → filamentous protonema (resembles green algae). Protonema branches, buds form → leafy gametophore. Photosynthetic.', icon: Icons.trending_up),
      BioStep(title: 'Gametophyte (Dominant)', detail: 'Leafy gametophyte (n) — the familiar moss plant. Anchored by rhizoids. Has leaf-like phyllids, stem-like caulid. Performs photosynthesis.', icon: Icons.park),
      BioStep(title: 'Sex Organs', detail: 'Antheridia (♂, club-shaped, produce antherozoids) and Archegonia (♀, flask-shaped, contain egg) develop on gametophyte tips. May be on same (monoecious) or different (dioecious) plants.', icon: Icons.people),
      BioStep(title: 'Fertilisation (Needs Water)', detail: 'Rain/dew: biflagellate antherozoids swim to archegonium, attracted chemically. Antherozoid + Egg → Zygote (2n) inside archegonium.', icon: Icons.water_drop),
      BioStep(title: 'Sporophyte Development', detail: 'Zygote (2n) develops into sporophyte in situ (within archegonium). Sporophyte: foot (haustorial, embedded in gametophyte) + seta + capsule (spore-bearing).', icon: Icons.trending_up),
      BioStep(title: 'Meiosis in Capsule', detail: 'Diploid spore mother cells in capsule undergo meiosis → haploid spores (n). Elaters (hygroscopic cells) aid spore dispersal in liverworts.', icon: Icons.call_split),
      BioStep(title: 'Cycle Repeats', detail: 'Spores dispersed → new gametophyte generation. Alternation of generations: Gametophyte (n, dominant) ↔ Sporophyte (2n, dependent).', icon: Icons.loop),
    ],
  ),

  BioProcess(
    id: 'pteridophyta_lifecycle',
    title: 'Life Cycle of Pteridophyta',
    chapter: 'Plant Kingdom',
    classLevel: 11,
    emoji: '🌿',
    color: _plant,
    description: 'Pteridophytes (ferns, horsetails, club mosses) — first vascular land plants. Sporophyte is dominant, independent; gametophyte (prothallus) is small, independent.',
    keyPoints: [
      'Dominant phase: SPOROPHYTE (2n, large, vascular, photosynthetic)',
      'Gametophyte = prothallus (n, small, heart-shaped, independent)',
      'First vascular plants with xylem and phloem',
      'Homosporous (one type of spore) — e.g., Dryopteris',
      'Heterosporous (micro- and megaspores) — e.g., Selaginella, Salvinia',
      'Sori on underside of fronds = clusters of sporangia',
      'Still require water for fertilisation',
    ],
    steps: [
      BioStep(title: 'Sporophyte (Dominant)', detail: 'Familiar fern plant (2n): roots, rhizome, fronds (leaves). Vascular tissue (xylem + phloem) present. Photosynthetic. Independent of gametophyte.', icon: Icons.park),
      BioStep(title: 'Sori & Sporangia', detail: 'Sori (clusters of sporangia) on abaxial (lower) surface of fronds, covered by indusium. Sporangia contain spore mother cells.', icon: Icons.bubble_chart),
      BioStep(title: 'Meiosis → Spores', detail: 'Spore mother cells (2n) undergo meiosis → haploid spores (n). Annulus (hygroscopic ring) in sporangium catapults spores. Wind-dispersed.', icon: Icons.call_split),
      BioStep(title: 'Spore Germination', detail: 'Haploid spore (n) germinates on moist soil → protonema (filamentous) → Prothallus (heart-shaped, 1-2 cm, n).', icon: Icons.eco),
      BioStep(title: 'Prothallus (Gametophyte)', detail: 'Prothallus: heart-shaped, 1-2 cm. Has chloroplasts (photosynthetic). Anchored by unicellular rhizoids. Independent but short-lived.', icon: Icons.favorite_border),
      BioStep(title: 'Sex Organs on Prothallus', detail: 'Antheridia (♂) at posterior end → multiflagellate antherozoids. Archegonia (♀) near notch → egg cell. Both on same prothallus (monoecious).', icon: Icons.people),
      BioStep(title: 'Fertilisation', detail: 'Water essential: antherozoids swim to archegonium. Zygote (2n) formed inside archegonium on prothallus. Embryo develops → young sporophyte.', icon: Icons.water_drop),
      BioStep(title: 'New Sporophyte', detail: 'Young sporophyte grows on prothallus initially, then becomes completely independent. Prothallus degenerates. Life cycle complete.', icon: Icons.loop),
    ],
  ),

  // ── Cell Cycle and Cell Division ──────────────────────────────────────────
  BioProcess(
    id: 'mitosis',
    title: 'Mitosis',
    chapter: 'Cell Cycle and Cell Division',
    classLevel: 11,
    emoji: '🔬',
    color: _cell,
    description: 'Equational division producing 2 genetically identical diploid daughter cells. Occurs in somatic cells for growth, repair, and asexual reproduction.',
    keyPoints: [
      'S phase: DNA replication → 4n DNA content (2n chromosomes, each with 2 chromatids)',
      'Prophase: chromosomes condense, nuclear envelope breaks, spindle forms',
      'Metaphase: chromosomes align at metaphase plate (clearest for karyotype)',
      'Anaphase: centromeres split, sister chromatids separate to poles',
      'Telophase: nuclear envelope reforms, chromosomes decondense',
      'Cytokinesis: cell plate (plants) or cleavage furrow (animals)',
      'Result: 2 cells, 2n, genetically identical to parent',
    ],
    steps: [
      BioStep(title: 'G1 Phase (Interphase)', detail: 'Cell grows, synthesises proteins. Restriction point: commitment to divide. G1 checkpoint: size, nutrients, growth factors. Duration variable (hours to years).', icon: Icons.timer),
      BioStep(title: 'S Phase', detail: 'DNA synthesis. Each chromosome replicated → 2 sister chromatids joined at centromere. 2n DNA → 4n DNA. Histones synthesised. Takes 6-8 hours.', icon: Icons.content_copy),
      BioStep(title: 'G2 Phase', detail: 'Cell continues growing. DNA repair. Synthesis of mitotic spindle proteins (tubulins). G2 checkpoint: is DNA fully replicated and undamaged?', icon: Icons.check),
      BioStep(title: 'Prophase', detail: 'Chromosomes condense (become visible). Nuclear envelope breaks down. Mitotic spindle forms from centrosomes (MTOCs). Nucleolus disappears. Chromosomes visible: 2n, each with 2 chromatids.', icon: Icons.radio_button_unchecked),
      BioStep(title: 'Metaphase', detail: 'Chromosomes align at metaphase plate (equatorial plane). Kinetochore fibres attach to kinetochores of each chromatid. Spindle checkpoint: all chromosomes bi-oriented?', icon: Icons.horizontal_rule),
      BioStep(title: 'Anaphase', detail: 'Cohesin cleaved (by separase). Sister chromatids separate → move to poles. Kinetochore fibres shorten, polar fibres elongate. Cell elongates.', icon: Icons.call_split),
      BioStep(title: 'Telophase', detail: 'Chromosomes reach poles, decondense. Nuclear envelope reforms around each set. Nucleolus reappears. Spindle depolymerises. Two nuclei formed.', icon: Icons.radio_button_checked),
      BioStep(title: 'Cytokinesis', detail: 'Animals: Actin-myosin ring pinches inward (cleavage furrow). Plants: Golgi vesicles form cell plate at middle → grows outward → new cell wall. 2 diploid cells formed.', icon: Icons.call_split),
    ],
  ),

  BioProcess(
    id: 'meiosis',
    title: 'Meiosis',
    chapter: 'Cell Cycle and Cell Division',
    classLevel: 11,
    emoji: '🧬',
    color: _cell,
    description: 'Reductional division producing 4 haploid cells from one diploid cell. Occurs in gonads/sporangia. Two consecutive divisions (Meiosis I and II) without DNA replication between.',
    keyPoints: [
      'Meiosis I: REDUCTIONAL (2n → n). Homologs separate.',
      'Meiosis II: EQUATIONAL (like mitosis). Sister chromatids separate.',
      'Prophase I is longest and most complex (5 sub-stages)',
      'Crossing over in Pachytene at chiasmata — genetic recombination',
      'Bivalents (tetrads): homologous pair of chromosomes at metaphase I',
      'Result: 4 haploid cells, genetically variable',
      'Restores ploidy after fertilisation; creates genetic diversity',
    ],
    steps: [
      BioStep(title: 'Prophase I — Leptotene', detail: 'Chromosomes begin condensation. Axial elements of synaptonemal complex form. DNA already replicated (4n DNA). Chromosomes become visible as thin threads.', icon: Icons.linear_scale),
      BioStep(title: 'Prophase I — Zygotene', detail: 'Synapsis: homologous chromosomes begin pairing using synaptonemal complex (SC). Chromosomes zipper together from multiple points. SC protein SYCP3.', icon: Icons.link),
      BioStep(title: 'Prophase I — Pachytene', detail: 'Synapsis complete. Bivalents fully formed (4 chromatids, 2 homologs). CROSSING OVER occurs at chiasmata. Recombination (exchange of segments). Longest sub-stage.', icon: Icons.swap_horizontal_circle),
      BioStep(title: 'Prophase I — Diplotene', detail: 'SC dissolves. Homologs repel but held at chiasmata. Chromosomes visible as bivalents with X-shaped chiasmata. In oocytes: arrested here for years (dictyotene).', icon: Icons.hub),
      BioStep(title: 'Prophase I — Diakinesis', detail: 'Chiasmata move to chromosome ends (terminalization). Chromosomes maximally condensed. Nuclear envelope dissolves. Spindle begins forming.', icon: Icons.radio_button_unchecked),
      BioStep(title: 'Metaphase I', detail: 'Bivalents align at metaphase plate. Homologs face opposite poles (bivalent orientation). Random assortment of maternal/paternal chromosomes. Spindle checkpoint.', icon: Icons.horizontal_rule),
      BioStep(title: 'Anaphase I', detail: 'Homologs separate (NOT sister chromatids — cohesin on arms cleaved, centromere cohesin protected by Shugoshin). Each chromosome = 2 chromatids. Chromosome number halved.', icon: Icons.call_split),
      BioStep(title: 'Telophase I & Meiosis II', detail: 'Two haploid cells with dyads (n chromosomes, each 2 chromatids). Brief interkinesis (no S phase). Meiosis II: like mitosis → 4 haploid cells (n, each chromosome = 1 chromatid).', icon: Icons.filter_alt),
    ],
  ),

  // ── Photosynthesis ────────────────────────────────────────────────────────
  BioProcess(
    id: 'z_scheme',
    title: 'Z-Scheme of Photosynthesis',
    chapter: 'Photosynthesis in Higher Plants',
    classLevel: 11,
    emoji: '☀️',
    color: _photo,
    description: 'The noncyclic electron transport pathway in light reactions. Electrons flow from water (PS-II) through electron carriers to NADP⁺ (PS-I), producing ATP and NADPH.',
    keyPoints: [
      'PS-II: P680 reaction centre (absorbs 680nm); oxidises water',
      '2H₂O → 4H⁺ + 4e⁻ + O₂ (photolysis, by OEC = Oxygen Evolving Complex)',
      'Electron transport: PQ → Cytb6f → PC → PS-I → Fd → NADP reductase',
      'PS-I: P700 reaction centre (absorbs 700nm); reduces NADP⁺ to NADPH',
      'Cytb6f pumps H⁺ → photophosphorylation (ATP synthesis)',
      'Z-shape because energy levels plotted on Y-axis',
      'Cyclic photophosphorylation: electrons cycle around PS-I only → ATP only',
    ],
    steps: [
      BioStep(title: 'Photon Absorption by PS-II (P680)', detail: 'Photon (λ=680nm) excites P680 reaction centre. Excited electron ejected from P680 to high energy state. P680⁺ (oxidised) is very strong oxidant.', icon: Icons.wb_sunny),
      BioStep(title: 'Water Splitting (Photolysis)', detail: 'P680⁺ oxidises water via Oxygen Evolving Complex (OEC, Mn cluster): 2H₂O → 4H⁺ + 4e⁻ + O₂. O₂ released as by-product. H⁺ released into lumen.', icon: Icons.water_drop),
      BioStep(title: 'Plastoquinone (PQ) — Mobile Carrier', detail: 'Energised e⁻ passes through pheophytin → PQ pool. PQ is lipid-soluble, mobile in thylakoid membrane. PQH₂ (plastoquinol) formed.', icon: Icons.moving),
      BioStep(title: 'Cytochrome b6f Complex', detail: 'PQH₂ donates e⁻ to Cyt b6f (analogous to Complex III in mitochondria). Q-cycle pumps additional H⁺ from stroma to lumen. Plastocyanin (PC) receives electrons.', icon: Icons.trending_up),
      BioStep(title: 'Photon Absorption by PS-I (P700)', detail: 'Photon (λ=700nm) excites P700 reaction centre. Electrons excited to very high energy level. P700⁺ receives e⁻ from plastocyanin (PC). e⁻ energy gap = Z-shape in diagram.', icon: Icons.flash_on),
      BioStep(title: 'Ferredoxin & NADP Reduction', detail: 'Excited e⁻ from P700 → Ferredoxin (Fd) → NADP⁺ reductase (FNR). FNR reduces NADP⁺: NADP⁺ + H⁺ + 2e⁻ → NADPH. NADPH used in Calvin cycle.', icon: Icons.charging_station),
      BioStep(title: 'ATP Synthesis (Photophosphorylation)', detail: 'H⁺ gradient (lumen > stroma) from water splitting + Cyt b6f pumping drives CF₀CF₁ ATP synthase. ADP + Pi → ATP. ~3H⁺ per ATP.', icon: Icons.flash_on),
      BioStep(title: 'Net Products', detail: 'Per 2 photons: 1 NADPH (PS-I), partial ATP synthesis. For Calvin cycle: 3ATP + 2NADPH needed per CO₂ fixed. Cyclic flow supplements ATP when needed.', icon: Icons.check_circle),
    ],
  ),

  BioProcess(
    id: 'chemiosmotic',
    title: 'Chemiosmotic Hypothesis',
    chapter: 'Photosynthesis in Higher Plants',
    classLevel: 11,
    emoji: '⚡',
    color: _photo,
    description: 'Peter Mitchell\'s hypothesis (1961, Nobel 1978) explaining ATP synthesis driven by proton (H⁺) electrochemical gradient across membranes. Applies to both chloroplasts and mitochondria.',
    keyPoints: [
      'Proton motive force (PMF) = H⁺ concentration gradient + membrane potential',
      'In chloroplasts: H⁺ accumulate in thylakoid LUMEN (from water splitting + Q-cycle)',
      'CF₀: transmembrane H⁺ channel (rotor). CF₁: catalytic head (stator)',
      'H⁺ flow through CF₀ rotates c-ring → conformational changes in CF₁',
      'Binding change mechanism: 3 active sites alternate (open→loose→tight)',
      '~3 H⁺ per ATP synthesised; ~4 H⁺ translocated per ATP in some models',
      'In mitochondria: H⁺ pumped into intermembrane space; ATP in matrix',
    ],
    steps: [
      BioStep(title: 'H⁺ Gradient Buildup (Chloroplast)', detail: 'Sources of lumen H⁺: (1) Water splitting at OEC (2H₂O → 4H⁺ + O₂ into lumen); (2) Q-cycle in Cyt b6f; (3) NADPH oxidation (stroma H⁺ consumed). Lumen becomes acidic (pH ~5) vs stroma (pH ~8).', icon: Icons.water),
      BioStep(title: 'Electrochemical Gradient', detail: 'H⁺ gradient: ΔpH (chemical) + Δψ (electrical) = Proton Motive Force (PMF). In thylakoids: mainly ΔpH drives ATP synthesis. In mitochondria: Δψ also important.', icon: Icons.trending_up),
      BioStep(title: 'CF₀ Subunit (Rotor)', detail: 'CF₀: embedded in thylakoid membrane. Consists of: a-subunit (H⁺ channel pathway), c-ring (8-14 subunits, rotates), b-subunits (stalk). H⁺ enters from lumen via half-channel in a-subunit.', icon: Icons.rotate_right),
      BioStep(title: 'c-Ring Rotation', detail: 'H⁺ binds to essential Asp/Glu on c-subunit. Ring rotates driven by H⁺ flow. Each c-subunit carries one H⁺ per revolution. 8-14 H⁺ per full rotation (one ATP per 120° rotation).', icon: Icons.rotate_right),
      BioStep(title: 'CF₁ Subunit (Catalytic Head)', detail: 'CF₁: α₃β₃γδε complex. γ-subunit (shaft) rotates with c-ring. β-subunits contain catalytic sites (3 per complex). γ rotation causes conformational changes in β-subunits.', icon: Icons.settings),
      BioStep(title: 'Binding Change Mechanism', detail: '3 β-sites cycle through states: Open (O) — binds ADP + Pi. Loose (L) — holds substrates. Tight (T) — synthesises ATP. γ rotation drives transition. ATP formed spontaneously at T-site.', icon: Icons.loop),
      BioStep(title: 'ATP Release', detail: 'Further rotation → T→O transition → ATP released from tight site. Chloroplast CF₁: ~4H⁺ per ATP. Net: 3 ATP per full 360° rotation (3 active sites).', icon: Icons.battery_std),
    ],
  ),

  BioProcess(
    id: 'c3_cycle',
    title: 'C3 Cycle (Calvin-Benson Cycle)',
    chapter: 'Photosynthesis in Higher Plants',
    classLevel: 11,
    emoji: '🔄',
    color: _photo,
    description: 'The dark reactions of photosynthesis (light-independent). CO₂ is fixed by RuBisCO into the 3-carbon compound 3-PGA. Uses ATP and NADPH from light reactions.',
    keyPoints: [
      'Occurs in stroma of chloroplast',
      'RuBisCO (ribulose-1,5-bisphosphate carboxylase/oxygenase) fixes CO₂',
      '3 CO₂ + 3 RuBP → 6 × 3-PGA (3-phosphoglycerate)',
      '6 × 3-PGA + 6ATP + 6NADPH → 6 G3P (glyceraldehyde-3-phosphate)',
      '5 G3P → regenerate 3 RuBP (using 3 ATP)',
      '1 G3P net output per 3 CO₂ fixed (used for glucose synthesis)',
      'Net: 3CO₂ + 9ATP + 6NADPH + 6H⁺ → G3P + 9Pi + 6NADP⁺ + 5H₂O',
    ],
    steps: [
      BioStep(title: 'Carbon Fixation', detail: 'RuBisCO (most abundant protein on Earth) catalyses: CO₂ + RuBP (5C, ribulose-1,5-bisphosphate) → unstable 6C intermediate → 2 × 3-PGA (3-phosphoglycerate, 3C). First stable product = 3C compound.', icon: Icons.add_circle),
      BioStep(title: 'Phosphorylation of 3-PGA', detail: '3-PGA phosphorylated by ATP: 3-PGA + ATP → 1,3-bisphosphoglycerate (1,3-BPG) + ADP. Phosphoglycerate kinase. One ATP per 3-PGA.', icon: Icons.flash_on),
      BioStep(title: 'Reduction to G3P', detail: '1,3-BPG reduced by NADPH: 1,3-BPG + NADPH + H⁺ → G3P + NADP⁺ + Pi. GAPDH (glyceraldehyde-3-phosphate dehydrogenase). G3P = first carbohydrate.', icon: Icons.arrow_downward),
      BioStep(title: 'G3P — Carbohydrate Synthesis', detail: '1/6 of G3P exits cycle for sucrose/starch synthesis. Glucose-6-phosphate → sucrose (transport) or starch (storage in chloroplast via ADP-glucose).', icon: Icons.output),
      BioStep(title: 'RuBP Regeneration', detail: '5/6 of G3P used to regenerate RuBP via complex series (involves aldolase, transketolase, phosphatases). Requires 3 ATP per cycle for phosphorylation of Ru5P → RuBP.', icon: Icons.loop),
      BioStep(title: 'Summary for 1 Glucose', detail: 'To make 1 glucose (6C): 6 turns of Calvin cycle. Uses: 6CO₂, 18ATP, 12NADPH. Gross 12 G3P produced; 10 used to regenerate RuBP, 2 net G3P → glucose.', icon: Icons.check_circle),
    ],
  ),

  BioProcess(
    id: 'c4_cycle',
    title: 'C4 Cycle (Hatch-Slack Pathway)',
    chapter: 'Photosynthesis in Higher Plants',
    classLevel: 11,
    emoji: '🌾',
    color: _photo,
    description: 'CO₂ concentration mechanism in plants like maize, sugarcane. CO₂ first fixed in mesophyll (as 4C compound), then transferred to bundle sheath for Calvin cycle. Avoids photorespiration.',
    keyPoints: [
      'C4 plants: maize, sugarcane, sorghum, Amaranthus, Atriplex',
      'Kranz anatomy: large bundle sheath cells + mesophyll cells',
      'Primary CO₂ acceptor: PEP (3C) in mesophyll cells; enzyme: PEP carboxylase',
      'PEP + CO₂ → OAA (4C) → Malate or Aspartate → bundle sheath',
      'Decarboxylation releases CO₂ → C3 cycle operates in bundle sheath',
      'No photorespiration (PEP carboxylase has no oxygenase activity)',
      'Optimal at high temperature, high light; water-use efficient',
    ],
    steps: [
      BioStep(title: 'CO₂ Fixation in Mesophyll', detail: 'PEP carboxylase (no oxygenase activity) in mesophyll cytoplasm fixes CO₂. PEP (3C) + CO₂ → OAA (oxaloacetate, 4C). Even at very low CO₂ concentrations.', icon: Icons.add_circle),
      BioStep(title: 'OAA → Malate/Aspartate', detail: 'OAA (4C) reduced to Malate (by NADP-MDH, uses NADPH) OR transaminated to Aspartate (in NAD-ME and PCK type plants). Type of 4C acid varies by C4 sub-type.', icon: Icons.transform),
      BioStep(title: 'Transport to Bundle Sheath', detail: 'Malate/Aspartate transported from mesophyll to bundle sheath cells via plasmodesmata. Bundle sheath cells have thick walls, many chloroplasts, no PS-II.', icon: Icons.arrow_forward),
      BioStep(title: 'Decarboxylation in Bundle Sheath', detail: 'Malate decarboxylated: Malate → Pyruvate + CO₂ (by NADP-ME). CO₂ released in bundle sheath → concentrated CO₂ around RuBisCO (high CO₂:O₂ ratio).', icon: Icons.call_split),
      BioStep(title: 'Calvin Cycle in Bundle Sheath', detail: 'High CO₂ concentration drives Calvin cycle efficiently in bundle sheath. RuBisCO fixes CO₂ (but oxygenase activity suppressed by high CO₂). Starch synthesised here.', icon: Icons.loop),
      BioStep(title: 'Pyruvate Return', detail: 'Pyruvate (3C) returns to mesophyll. Pyruvate phosphate dikinase (PPDK) regenerates PEP: Pyruvate + ATP + Pi → PEP + AMP + PPi. 2 ATP equivalents per CO₂ transported.', icon: Icons.undo),
      BioStep(title: 'Net Advantage', detail: 'Extra cost: 2 ATP per CO₂ (vs C3). Benefit: no photorespiration, more efficient at high temperature and light, better water use efficiency (stomata partially closed). Better adapted to tropical conditions.', icon: Icons.check_circle),
    ],
  ),

  // ── Respiration ────────────────────────────────────────────────────────────
  BioProcess(
    id: 'oxidative_phosphorylation',
    title: 'Oxidative Phosphorylation (ETC)',
    chapter: 'Respiration in Plants',
    classLevel: 11,
    emoji: '⚡',
    color: _resp,
    description: 'ATP synthesis coupled to electron transport in inner mitochondrial membrane. NADH and FADH₂ from glycolysis and Krebs cycle oxidised; electrons transferred to O₂ with ATP synthesis.',
    keyPoints: [
      'Occurs on inner mitochondrial membrane (cristae)',
      'Complexes: I (NADH dehydrogenase), II (Succinate DH), III (Cyt bc1), IV (Cyt oxidase)',
      'Complex I, III, IV pump H⁺ into intermembrane space',
      'Complex V (ATP synthase): H⁺ re-entry drives ATP synthesis',
      'NADH: 2.5 ATP; FADH₂: 1.5 ATP (P/O ratios, modern values)',
      'Final electron acceptor: O₂ → H₂O (via Complex IV)',
      'Cyanide/CO poison Complex IV; DNP uncouples gradient',
    ],
    steps: [
      BioStep(title: 'NADH & FADH₂ from Krebs', detail: 'Each acetyl CoA → 3 NADH + 1 FADH₂ + 1 GTP in Krebs cycle. Glycolysis also produces 2 NADH (cytoplasmic). These feed into ETC.', icon: Icons.input),
      BioStep(title: 'Complex I (NADH Dehydrogenase)', detail: 'NADH → NAD⁺ + H⁺ + 2e⁻. Electrons passed to ubiquinone (CoQ). Pumps 4H⁺ across membrane per NADH. FMN prosthetic group. Site of rotenone inhibition.', icon: Icons.electric_bolt),
      BioStep(title: 'Complex II (Succinate DH)', detail: 'FADH₂ → FAD + 2H⁺ + 2e⁻. Directly oxidises succinate in Krebs cycle. Passes e⁻ to CoQ. Does NOT pump H⁺ (so FADH₂ yields fewer ATP than NADH).', icon: Icons.remove_circle_outline),
      BioStep(title: 'Ubiquinone (CoQ) — Mobile Carrier', detail: 'Lipid-soluble, mobile in membrane. Accepts e⁻ from Complex I and II → CoQH₂ (ubiquinol). Transfers to Complex III.', icon: Icons.moving),
      BioStep(title: 'Complex III (Cytochrome bc1)', detail: 'CoQH₂ → CoQ + 2H⁺ + 2e⁻. Q-cycle: pumps 4H⁺ per 2e⁻. Cytochrome c (small, mobile) receives electrons. Site of antimycin A inhibition.', icon: Icons.electric_bolt),
      BioStep(title: 'Complex IV (Cytochrome c Oxidase)', detail: '4 Cyt c molecules donate e⁻. O₂ + 4H⁺ + 4e⁻ → 2H₂O. Pumps 2H⁺ per 2e⁻. Contains heme a, a3 and Cu centres. Site of cyanide and CO inhibition.', icon: Icons.water_drop),
      BioStep(title: 'ATP Synthase (Complex V)', detail: 'H⁺ gradient drives F₀F₁ ATP synthase. H⁺ re-enter matrix through F₀ → rotates γ-subunit → conformational changes in β-subunits → ADP + Pi → ATP. ~2.5 ATP per NADH, 1.5 per FADH₂.', icon: Icons.battery_std),
      BioStep(title: 'Net ATP from One Glucose', detail: 'Glycolysis: 2 ATP + 2 NADH; Pyruvate oxidation: 2 NADH; Krebs: 2 ATP + 6 NADH + 2 FADH₂. ETC: ~27 ATP. Total: ~30-32 ATP per glucose (revised from old estimate of 36-38).', icon: Icons.check_circle),
    ],
  ),

  // ── Body Fluids and Circulation ──────────────────────────────────────────
  BioProcess(
    id: 'blood_circulation',
    title: 'Blood Circulation Through Heart',
    chapter: 'Body Fluids and Circulation',
    classLevel: 11,
    emoji: '❤️',
    color: _circ,
    description: 'Double circulation: pulmonary (heart→lungs→heart) and systemic (heart→body→heart) circuits. Each complete in one cardiac cycle (~0.8 sec at 72 bpm).',
    keyPoints: [
      'SAN (Sino-Atrial Node) = pacemaker; initiates each heartbeat',
      'SAN → AVN (AV Node) → Bundle of His → Purkinje fibres',
      'Right side: deoxygenated blood; Left side: oxygenated',
      'Cardiac output = Stroke Volume × Heart Rate = 70ml × 72bpm = 5.04 L/min',
      'Systole: 0.3s (ventricles contract); Diastole: 0.5s',
      'Valves: AV valves (tricuspid, bicuspid/mitral); Semilunar valves',
      'Korotkoff sounds: systolic 120mmHg, diastolic 80mmHg (normal)',
    ],
    steps: [
      BioStep(title: 'Deoxygenated Blood Returns', detail: 'Deoxygenated blood from systemic circulation returns via Superior Vena Cava (upper body) and Inferior Vena Cava (lower body) → Right Atrium (RA).', icon: Icons.arrow_back),
      BioStep(title: 'Right Atrium → Right Ventricle', detail: 'RA contracts (atrial systole). Tricuspid valve (3 cusps) opens. Blood flows to Right Ventricle (RV). Tricuspid closes to prevent backflow during ventricular systole.', icon: Icons.arrow_downward),
      BioStep(title: 'Pulmonary Circuit', detail: 'RV contracts (ventricular systole). Pulmonary semilunar valve opens. Blood → Pulmonary Trunk → Left and Right Pulmonary Arteries → Lungs. CO₂ exchanged for O₂.', icon: Icons.air),
      BioStep(title: 'Oxygenated Blood Returns', detail: 'Oxygenated blood from lungs via 4 Pulmonary Veins → Left Atrium (LA). Pulmonary veins are only veins carrying oxygenated blood.', icon: Icons.arrow_forward),
      BioStep(title: 'Left Atrium → Left Ventricle', detail: 'LA contracts. Bicuspid (Mitral) valve (2 cusps) opens → blood into Left Ventricle (LV). LV wall is thickest (must push blood to entire body).', icon: Icons.arrow_downward),
      BioStep(title: 'Systemic Circuit', detail: 'LV contracts. Aortic semilunar valve opens. Blood → Aorta → Arteries → Arterioles → Capillaries (tissue exchange) → Venules → Veins → Venae Cavae.', icon: Icons.hub),
      BioStep(title: 'Cardiac Conduction System', detail: 'SAN (RA wall, 72/min) → impulse spreads across atria → AVN (delay 0.1s) → Bundle of His → Right/Left bundle branches → Purkinje fibres → ventricular muscle.', icon: Icons.electric_bolt),
      BioStep(title: 'ECG & Cardiac Cycle', detail: 'P wave: atrial depolarisation. QRS: ventricular depolarisation. T wave: ventricular repolarisation. Cardiac cycle: Atrial systole (0.1s) + Ventricular systole (0.3s) + Joint diastole (0.4s) = 0.8s.', icon: Icons.favorite),
    ],
  ),

  // ── Excretion ─────────────────────────────────────────────────────────────
  BioProcess(
    id: 'counter_current',
    title: 'Counter-Current Mechanism (Kidney)',
    chapter: 'Excretory Products and Their Elimination',
    classLevel: 11,
    emoji: '🫘',
    color: _excrete,
    description: 'The loop of Henle creates a hyperosmotic gradient in the renal medulla (up to 1200 mOsm/L). This concentrates urine when ADH makes the collecting duct permeable.',
    keyPoints: [
      'Only juxtamedullary nephrons have long loops of Henle extending into medulla',
      'Descending limb: permeable to H₂O, impermeable to solutes',
      'Ascending limb (thick): impermeable to H₂O, actively pumps Na⁺/Cl⁻',
      'Countercurrent multiplier builds corticomedullary osmotic gradient',
      'Vasa recta (countercurrent exchanger) maintains gradient (does not wash it out)',
      'ADH increases collecting duct permeability → water reabsorption',
      'Without ADH: dilute urine; Max concentration with ADH: 1200 mOsm/L',
    ],
    steps: [
      BioStep(title: 'Cortical vs Juxtamedullary', detail: 'Juxtamedullary nephrons (long loop): create concentration gradient. Cortical nephrons (short loop): only filtration. ~15% juxtamedullary in humans.', icon: Icons.hub),
      BioStep(title: 'Filtrate Enters Descending Limb', detail: 'Glomerular filtrate (~300 mOsm) enters descending thin limb. Descending limb is permeable to water, slightly permeable to solutes. Water exits by osmosis into hypertonic interstitium.', icon: Icons.water_drop),
      BioStep(title: 'Concentration Increases Descending', detail: 'As filtrate descends deeper into medulla, more water exits → tubular fluid becomes more concentrated. At hairpin turn: ~1200 mOsm. Equilibrated with interstitium.', icon: Icons.trending_up),
      BioStep(title: 'Ascending Limb — Impermeable to Water', detail: 'Thin ascending limb: slightly permeable to NaCl; thick ascending limb: actively pumps Na⁺/K⁺/2Cl⁻ (NKCC2 transporter, furosemide-sensitive). Water CANNOT follow (impermeable).', icon: Icons.water_drop),
      BioStep(title: 'Building the Gradient', detail: 'As NaCl is pumped out of ascending limb, medullary interstitium becomes hyperosmotic. Tubular fluid becomes progressively dilute as it ascends (~100 mOsm at DCT entry).', icon: Icons.trending_down),
      BioStep(title: 'Vasa Recta (Countercurrent Exchange)', detail: 'Vasa recta descend: absorb solutes, lose water → concentrated at tip. Ascend: lose solutes, gain water → diluted at cortex. Net: minimal washout of medullary gradient.', icon: Icons.loop),
      BioStep(title: 'ADH and Collecting Duct', detail: 'ADH (vasopressin) from posterior pituitary. Binds V2 receptor on collecting duct → inserts aquaporin-2 channels → water reabsorption. Without ADH: diabetes insipidus (large dilute urine).', icon: Icons.settings),
      BioStep(title: 'Urea Recycling', detail: 'Inner medullary collecting duct (ADH present): also permeable to urea. Urea (from protein metabolism) adds to medullary hyperosmolarity. Urea recycled from collecting duct → loop → vasa recta.', icon: Icons.loop),
    ],
  ),

  // ── Locomotion and Movement ──────────────────────────────────────────────
  BioProcess(
    id: 'sliding_filament',
    title: 'Sliding Filament Theory',
    chapter: 'Locomotion and Movement',
    classLevel: 11,
    emoji: '💪',
    color: _muscle,
    description: 'Huxley & Hanson (1954) model explaining muscle contraction. Thick myosin filaments slide relative to thin actin filaments (neither shortens). Requires Ca²⁺ and ATP.',
    keyPoints: [
      'Sarcomere: functional unit. Z-line to Z-line. A-band constant during contraction',
      'A-band (myosin+actin overlap): stays same length. I-band shortens. H-zone disappears',
      'Ca²⁺ from SR (sarcoplasmic reticulum) released on action potential',
      'Ca²⁺ binds Troponin C → Tropomyosin shifts → actin binding site exposed',
      'Myosin head (ATPase) binds actin → power stroke → filaments slide',
      '1 ATP per cross-bridge cycle; rigor mortis when no ATP',
      'One twitch = 1 AP + Ca²⁺ release + cross-bridge cycle',
    ],
    steps: [
      BioStep(title: 'Motor Neuron → NMJ', detail: 'Action potential reaches motor neuron terminal. ACh released into synaptic cleft. Binds nicotinic ACh receptors on sarcolemma → end plate potential → action potential in muscle fibre.', icon: Icons.flash_on),
      BioStep(title: 'T-tubule & Ca²⁺ Release', detail: 'AP travels along sarcolemma and into T-tubules. Depolarisation sensed by DHPR (voltage sensor) → RyR1 (ryanodine receptor) on SR opens → Ca²⁺ floods sarcoplasm (~100x increase).', icon: Icons.water_drop),
      BioStep(title: 'Ca²⁺ Binds Troponin C', detail: 'Ca²⁺ binds Troponin C (in Troponin-Tropomyosin complex on thin filament). Conformational change in Troponin → Tropomyosin shifts (moves ~1.5nm) → exposes myosin-binding sites on actin.', icon: Icons.lock_open),
      BioStep(title: 'Cross-Bridge Formation', detail: 'Myosin head (with ADP + Pi bound = high energy, cocked state) binds to exposed actin site. Cross-bridge formed. ADP + Pi release triggers power stroke.', icon: Icons.link),
      BioStep(title: 'Power Stroke', detail: 'Myosin head rotates ~45° (power stroke). Actin filament pulled toward M-line by ~5-10 nm per stroke. ADP + Pi released. Force generated ~3-4 pN per cross-bridge.', icon: Icons.arrow_forward),
      BioStep(title: 'ATP Binding → Detachment', detail: 'ATP binds to myosin head → reduced affinity for actin → cross-bridge detaches. ATPase activity: ATP hydrolysed → ADP + Pi. Head "cocked" (returns to 90° = high energy). Ready for next cycle.', icon: Icons.refresh),
      BioStep(title: 'Sarcomere Shortening', detail: 'Multiple cross-bridge cycles (asynchronous): actin slides over myosin toward M-line. Z-lines come closer. I-band shortens. H-zone disappears. A-band length unchanged (myosin doesn\'t shorten).', icon: Icons.compress),
      BioStep(title: 'Relaxation', detail: 'AP stops → Ca²⁺ pumped back into SR by SERCA (Ca²⁺-ATPase, ATP required). [Ca²⁺] falls → Troponin releases Ca²⁺ → Tropomyosin covers binding sites → cross-bridges detach → relaxation.', icon: Icons.refresh),
    ],
  ),

  // ── Neural Control ────────────────────────────────────────────────────────
  BioProcess(
    id: 'action_potential',
    title: 'Action Potential Propagation',
    chapter: 'Neural Control and Coordination',
    classLevel: 11,
    emoji: '⚡',
    color: _neuro,
    description: 'The nerve impulse: an all-or-none electrical signal propagated along the axon membrane due to sequential opening and closing of voltage-gated Na⁺ and K⁺ channels.',
    keyPoints: [
      'Resting potential: -70 mV (maintained by Na⁺-K⁺ ATPase: 3Na⁺ out, 2K⁺ in)',
      'Threshold: -55 mV. Action potential all-or-none above threshold',
      'Depolarisation: Na⁺ channels open → Na⁺ rushes in → +30 to +40 mV',
      'Repolarisation: Na⁺ channels inactivate + K⁺ channels open → K⁺ out',
      'Afterhyperpolarisation: K⁺ channels close slowly → -80 mV briefly',
      'Refractory period: absolute (Na⁺ channels inactivated) → no new AP',
      'Saltatory conduction in myelinated fibres: AP jumps between nodes of Ranvier',
    ],
    steps: [
      BioStep(title: 'Resting State (-70 mV)', detail: 'Na⁺-K⁺ ATPase maintains: high [K⁺] inside, high [Na⁺] outside. K⁺ leak channels: K⁺ flows out (concentration gradient) → interior negative. Membrane polarised at -70 mV.', icon: Icons.battery_std),
      BioStep(title: 'Stimulus → Threshold', detail: 'Depolarising stimulus brings membrane from -70 mV toward threshold (-55 mV). Below threshold: graded potential (decremental). At/above threshold: AP triggered (all-or-none law).', icon: Icons.flash_on),
      BioStep(title: 'Depolarisation Phase', detail: 'Voltage-gated Na⁺ channels open rapidly (activation gate opens). Na⁺ rushes in (electrochemical gradient). Membrane rapidly depolarises: -70 → +30 mV (overshoot). Na⁺ equilibrium potential = +60 mV.', icon: Icons.trending_up),
      BioStep(title: 'Repolarisation Phase', detail: 'Na⁺ channels inactivate (ball-and-chain inactivation gate closes, ~1 ms after opening). Voltage-gated K⁺ channels open (slower, delayed). K⁺ flows OUT. Membrane repolarises: +30 → -70 mV.', icon: Icons.trending_down),
      BioStep(title: 'Afterhyperpolarisation', detail: 'K⁺ channels close slowly → K⁺ continues to flow out briefly after repolarisation → membrane overshoots to ~-80 mV (afterhyperpolarisation/undershoot). Returns to -70 mV as K⁺ channels fully close.', icon: Icons.arrow_downward),
      BioStep(title: 'Refractory Period', detail: 'Absolute refractory: Na⁺ channels inactivated → no AP possible regardless of stimulus. Relative refractory: partially recovered → need stronger stimulus. Ensures one-directional propagation.', icon: Icons.lock),
      BioStep(title: 'Propagation (Unmyelinated)', detail: 'Depolarised region → local currents depolarise adjacent membrane → Na⁺ channels open in adjacent region. Refractory region prevents backward propagation. Conduction velocity: 0.5-2 m/s.', icon: Icons.arrow_forward),
      BioStep(title: 'Saltatory Conduction (Myelinated)', detail: 'Myelin sheath (Schwann cells, PNS; oligodendrocytes, CNS) insulates axon. AP jumps between Nodes of Ranvier (unmyelinated gaps). Conduction velocity: 70-120 m/s. Much faster and energy-efficient.', icon: Icons.skip_next),
    ],
  ),

  BioProcess(
    id: 'hormone_mechanism',
    title: 'Mechanism of Hormone Action',
    chapter: 'Chemical Coordination and Integration',
    classLevel: 11,
    emoji: '🧪',
    color: _neuro,
    description: 'Hormones act via specific receptors. Water-soluble hormones use cell-surface receptors and second messengers; lipid-soluble hormones enter cells and act on nuclear receptors.',
    keyPoints: [
      'Water-soluble (peptide/amine): cannot cross membrane → cell surface receptor',
      'Lipid-soluble (steroid/thyroid): cross membrane → intracellular receptor',
      'Second messenger: cAMP, cGMP, IP₃, Ca²⁺, DAG (G-protein coupled)',
      'cAMP pathway: hormone → GPCR → Gα-GTP → adenylyl cyclase → cAMP → PKA',
      'PKA phosphorylates target proteins → cellular response (rapid, amplified)',
      'Steroid hormones: receptor in cytoplasm/nucleus → HRE on DNA → gene expression',
      'Steroid effects: slow onset but long duration; peptide: rapid onset, short duration',
    ],
    steps: [
      BioStep(title: 'Hormone Secretion', detail: 'Endocrine gland releases hormone into blood in response to neural/hormonal/humoral signals. Transported in blood (some bound to carrier proteins — especially steroids and thyroid hormones).', icon: Icons.output),
      BioStep(title: 'Type 1: Water-Soluble Hormone', detail: 'Peptide/protein hormones (insulin, glucagon, FSH, LH, ADH, oxytocin) and catecholamines (adrenaline) cannot cross plasma membrane. Bind specific receptors on cell surface.', icon: Icons.lock),
      BioStep(title: 'Receptor Activation & G-Protein', detail: 'Hormone binds GPCR (G-protein coupled receptor) → conformational change → Gα subunit exchanges GDP for GTP → activates effector protein (adenylyl cyclase or PLC).', icon: Icons.settings),
      BioStep(title: 'Second Messenger (cAMP)', detail: 'Adenylyl cyclase: ATP → cAMP (cyclic AMP). cAMP activates Protein Kinase A (PKA). PKA phosphorylates target proteins → rapid cellular response. Signal amplified (1 hormone → thousands of cAMP).', icon: Icons.flash_on),
      BioStep(title: 'Alternate: IP₃/DAG Pathway', detail: 'PLC pathway: PLC cleaves PIP₂ → IP₃ + DAG. IP₃ opens ER Ca²⁺ channels → [Ca²⁺] rises → Ca²⁺/calmodulin activates kinases. DAG activates PKC. Used by some GPCR and RTK-linked hormones.', icon: Icons.call_split),
      BioStep(title: 'Type 2: Lipid-Soluble Hormones', detail: 'Steroid hormones (cortisol, oestrogen, testosterone, aldosterone) and thyroid hormones (T₃, T₄) are lipophilic → diffuse through plasma membrane freely.', icon: Icons.login),
      BioStep(title: 'Intracellular Receptor → HRE', detail: 'Steroid hormones bind intracellular receptors (heat shock protein dissociates). Hormone-receptor complex enters nucleus. Binds Hormone Response Element (HRE) in DNA. Acts as transcription factor.', icon: Icons.description),
      BioStep(title: 'Gene Expression → Slow Response', detail: 'Altered transcription → new mRNA → new protein synthesis → cellular response. Slow onset (hours) but prolonged effect (days). Example: cortisol → PEPCK induction → gluconeogenesis; oestrogen → uterine proliferation.', icon: Icons.slow_motion_video),
    ],
  ),
];

// ── Helper: group by class level ──────────────────────────────────────────

List<BioProcess> get class11Processes =>
    bioProcesses.where((p) => p.classLevel == 11).toList();

List<BioProcess> get class12Processes =>
    bioProcesses.where((p) => p.classLevel == 12).toList();

Map<String, List<BioProcess>> groupByChapter(List<BioProcess> processes) {
  final map = <String, List<BioProcess>>{};
  for (final p in processes) {
    map.putIfAbsent(p.chapter, () => []).add(p);
  }
  return map;
}
