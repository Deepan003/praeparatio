import '../../models/flashcard_model.dart';

// ignore_for_file: non_constant_identifier_names

/// Hard-coded NCERT Biology flashcards — 15-20 per chapter.
/// Generated from NCERT Class 11 & 12 Biology textbooks.
class FlashcardData {
  static final List<FlashcardModel> all = [
    ..._ch1, ..._ch2, ..._ch3, ..._ch4, ..._ch5,
    ..._ch6, ..._ch7, ..._ch8, ..._ch9, ..._ch10,
    ..._ch11, ..._ch12, ..._ch13, ..._ch14, ..._ch15,
    ..._ch16, ..._ch17, ..._ch18, ..._ch19, ..._ch20,
    ..._ch21, ..._ch22,
    // Class 12
    ..._c12_1, ..._c12_2, ..._c12_3, ..._c12_4, ..._c12_5,
    ..._c12_6, ..._c12_7, ..._c12_8, ..._c12_9, ..._c12_10,
    ..._c12_11, ..._c12_12, ..._c12_13, ..._c12_14, ..._c12_15,
    ..._c12_16,
  ];

  static FlashcardModel _f(String id, String ch, String front, String back, {String cls = '11', String cat = 'fact'}) =>
      FlashcardModel(id: id, chapter: ch, front: front, back: back, category: cat, studentClass: cls);

  // ─── CLASS 11 ───────────────────────────────────────────────

  static final _ch1 = <FlashcardModel>[
    _f('c11_1_1',  'The Living World', 'What is biodiversity?', 'The number and types of organisms present on Earth. India is a megadiverse country with ~8% of total species.'),
    _f('c11_1_2',  'The Living World', 'Define metabolism.', 'The sum total of all chemical reactions occurring inside a living organism. Unique to living organisms.'),
    _f('c11_1_3',  'The Living World', 'What is homeostasis?', 'Tendency of living organisms to maintain a stable internal environment despite external changes.'),
    _f('c11_1_4',  'The Living World', 'Who coined the term "Taxonomy"?', 'Carolus Linnaeus. He also proposed the binomial nomenclature system.'),
    _f('c11_1_5',  'The Living World', 'What is a taxon?', 'A unit of classification at any level of the taxonomic hierarchy (e.g., phylum, class, order).'),
    _f('c11_1_6',  'The Living World', 'Arrange taxonomic hierarchy highest to lowest.', 'Kingdom → Phylum → Class → Order → Family → Genus → Species. Mnemonic: King Philip Came Over For Good Soup.'),
    _f('c11_1_7',  'The Living World', 'Rules for binomial nomenclature.', '1. Generic name starts with capital; species with lower case. 2. Printed in italics; handwritten underlined separately. E.g., Mangifera indica.'),
    _f('c11_1_8',  'The Living World', 'What is ICZN?', 'International Code of Zoological Nomenclature — governs naming of animals.'),
    _f('c11_1_9',  'The Living World', 'What is a herbarium?', 'A storehouse of collected dried plant specimens mounted on sheets for reference.'),
    _f('c11_1_10', 'The Living World', 'Name the three types of museum collections.', '1. Zoological Survey of India (ZSI), 2. Botanical Survey of India (BSI), 3. National museums.'),
    _f('c11_1_11', 'The Living World', 'What is a key in taxonomy?', 'A device used for identification of plants and animals based on contrasting characters (dichotomous).'),
    _f('c11_1_12', 'The Living World', 'Define species.', 'A group of organisms sharing common characters and capable of interbreeding to produce fertile offspring.'),
    _f('c11_1_13', 'The Living World', 'What is growth in living organisms?', 'Increase in mass and number of individuals. Can be intrinsic (from inside) unlike non-living objects.'),
    _f('c11_1_14', 'The Living World', 'What is reproduction?', 'The ability to produce offspring of their own kind. Considered a defining feature but mules are sterile — so it is not the only criterion.'),
    _f('c11_1_15', 'The Living World', 'What distinguishes living from non-living things?', 'Cellular organisation, metabolism, growth (intrinsic), reproduction, response to stimuli, homeostasis, consciousness.'),
  ];

  static final _ch2 = <FlashcardModel>[
    _f('c11_2_1',  'Biological Classification', 'Who proposed the two-kingdom classification?', 'Carolus Linnaeus — Plantae and Animalia.'),
    _f('c11_2_2',  'Biological Classification', 'Who proposed the five-kingdom classification?', 'R.H. Whittaker (1969). Kingdoms: Monera, Protista, Fungi, Plantae, Animalia.'),
    _f('c11_2_3',  'Biological Classification', 'Basis of Whittaker\'s classification.', 'Cell structure, mode of nutrition, body organisation, reproduction, phylogenetic relationships.'),
    _f('c11_2_4',  'Biological Classification', 'Characteristics of Monera.', 'Prokaryotes; no nuclear membrane; unicellular; includes bacteria, cyanobacteria, archaebacteria, mycoplasma.'),
    _f('c11_2_5',  'Biological Classification', 'What are archaebacteria? Give examples.', 'Ancient bacteria living in extreme conditions. E.g., methanogens (marshes), halophiles (salt lakes), thermoacidophiles (hot springs).'),
    _f('c11_2_6',  'Biological Classification', 'What is cyanobacteria?', 'Photosynthetic prokaryotes (blue-green algae); important nitrogen fixers (Nostoc, Anabaena). Cause algal blooms.'),
    _f('c11_2_7',  'Biological Classification', 'Characteristics of Protista.', 'Eukaryotic unicellular organisms; autotrophic or heterotrophic; mostly aquatic. E.g., Amoeba, Euglena, Paramoecium, dinoflagellates.'),
    _f('c11_2_8',  'Biological Classification', 'What are chrysophytes?', 'Include diatoms and golden algae. Chief producers in oceans. Cell walls embedded with silica → diatomaceous earth used in filtration.'),
    _f('c11_2_9',  'Biological Classification', 'Characteristics of Fungi.', 'Eukaryotic; heterotrophic (saprophytic/parasitic); cell wall of chitin; mycelium of hyphae; store glycogen.'),
    _f('c11_2_10', 'Biological Classification', 'What are mycorrhiza?', 'Fungus–root symbiotic association. Fungus helps absorption of water and minerals; plant provides organic nutrition.'),
    _f('c11_2_11', 'Biological Classification', 'Classes of fungi with examples.', 'Phycomycetes (Rhizopus), Ascomycetes (Penicillium, yeast), Basidiomycetes (Agaricus, puffballs), Deuteromycetes (Alternaria, Trichoderma).'),
    _f('c11_2_12', 'Biological Classification', 'What are viruses?', 'Non-cellular entities; obligate intracellular parasites; contain DNA or RNA (never both) enclosed in protein coat (capsid); discovered by Ivanowsky (TMV).'),
    _f('c11_2_13', 'Biological Classification', 'What are viroids?', 'Infectious RNA without protein coat; smaller than viruses; cause plant diseases (potato spindle tuber disease). Discovered by T.O. Diener.'),
    _f('c11_2_14', 'Biological Classification', 'What are prions?', 'Misfolded proteins that cause diseases like BSE (mad cow disease) and kuru in humans.'),
    _f('c11_2_15', 'Biological Classification', 'What are lichens?', 'Symbiotic association between fungi (mycobiont) and algae (phycobiont). Excellent pollution indicators (sensitive to SO₂).'),
  ];

  static final _ch3 = <FlashcardModel>[
    _f('c11_3_1',  'Plant Kingdom', 'What are algae? Classification.', 'Chlorophyll-bearing thallophytes. Three classes: Chlorophyceae (green), Phaeophyceae (brown), Rhodophyceae (red).'),
    _f('c11_3_2',  'Plant Kingdom', 'Reserve food of Chlorophyceae, Phaeophyceae, Rhodophyceae.', 'Green algae: starch. Brown algae: mannitol & laminarin. Red algae: floridean starch.'),
    _f('c11_3_3',  'Plant Kingdom', 'What is agar? Source?', 'Polysaccharide used in culture media; derived from red algae (Gelidium, Gracilaria).'),
    _f('c11_3_4',  'Plant Kingdom', 'What are bryophytes?', 'Amphibians of plant kingdom; no vascular tissue; dependent on water for reproduction. E.g., Marchantia (liverwort), Funaria (moss).'),
    _f('c11_3_5',  'Plant Kingdom', 'Economic importance of Sphagnum (peat moss).', 'Used as packing material for transshipment of live plants; can hold water 18× its weight; used as fuel.'),
    _f('c11_3_6',  'Plant Kingdom', 'Features of pteridophytes.', 'First vascular land plants; independent sporophyte; spores germinate into heart-shaped prothallus. E.g., Selaginella, Adiantum, Equisetum.'),
    _f('c11_3_7',  'Plant Kingdom', 'What are gymnosperms?', '"Naked seed" plants; seeds not enclosed in fruit; heterosporous; e.g., Cycas, Pinus, Gnetum.'),
    _f('c11_3_8',  'Plant Kingdom', 'What is double fertilization? Where does it occur?', 'Unique to angiosperms: one sperm + egg = zygote; another sperm + 2 polar nuclei = triploid PEN.'),
    _f('c11_3_9',  'Plant Kingdom', 'Difference between homosporous and heterosporous.', 'Homosporous: one kind of spore (most pteridophytes). Heterosporous: micro- and megaspores (Selaginella, all gymnosperms, angiosperms).'),
    _f('c11_3_10', 'Plant Kingdom', 'What is alternation of generations?', 'In plant life cycles: alternation between haploid gametophyte and diploid sporophyte. Gametophyte dominant in bryophytes; sporophyte dominant in higher plants.'),
    _f('c11_3_11', 'Plant Kingdom', 'Economic importance of algae.', 'Produce ~50% of Earth\'s O₂; fix CO₂; Chlorella used as food supplement; algin (brown algae) in ice cream; carrageenan (red algae) in cosmetics.'),
    _f('c11_3_12', 'Plant Kingdom', 'What is the national tree of India?', 'Ficus benghalensis — Banyan tree (angiosperm).'),
    _f('c11_3_13', 'Plant Kingdom', 'Ovule in gymnosperms vs angiosperms.', 'Gymnosperms: ovules naked on megasporophylls. Angiosperms: ovules enclosed inside ovary.'),
    _f('c11_3_14', 'Plant Kingdom', 'What is protonema?', 'Juvenile stage in moss life cycle that develops from germinating spore; green, filamentous.'),
  ];

  static final _ch4 = <FlashcardModel>[
    _f('c11_4_1',  'Animal Kingdom', 'Basis of animal classification.', 'Levels of organisation, symmetry, body cavity (coelom), segmentation, notochord, diploblastic/triploblastic.'),
    _f('c11_4_2',  'Animal Kingdom', 'What is coelom?', 'Body cavity lined by mesoderm. Coelomates (true coelom), pseudocoelomates (body cavity not lined by mesoderm), acoelomates (no cavity).'),
    _f('c11_4_3',  'Animal Kingdom', 'Characteristics of Porifera.', 'Cellular level of organisation; pore-bearing; spongocoel lined by choanocytes; skeleton of spicules/spongin; e.g., Sycon, Euspongia, Spongilla.'),
    _f('c11_4_4',  'Animal Kingdom', 'Characteristics of Coelenterata (Cnidaria).', 'Tissue level; diploblastic; radial symmetry; cnidoblasts for stinging; e.g., Hydra, Aurelia (jellyfish), Adamsia (sea anemone).'),
    _f('c11_4_5',  'Animal Kingdom', 'What is metagenesis?', 'Alternation of asexual (polyp) and sexual (medusa) phases in coelenterates.'),
    _f('c11_4_6',  'Animal Kingdom', 'Characteristics of Platyhelminthes.', 'Acoelomate; bilaterally symmetrical; triploblastic; flame cells for excretion; e.g., Fasciola (liver fluke), Taenia (tapeworm).'),
    _f('c11_4_7',  'Animal Kingdom', 'Characteristics of Nematoda (Aschelminthes).', 'Pseudocoelomate; cylindrical; complete digestive system; dioecious; e.g., Ascaris, Wuchereria (filarial worm).'),
    _f('c11_4_8',  'Animal Kingdom', 'Characteristics of Annelida.', 'True coelom; segmentation (metamerism); nephridia for excretion; e.g., Nereis, earthworm (Pheretima), Hirudinaria (leech).'),
    _f('c11_4_9',  'Animal Kingdom', 'Characteristics of Arthropoda.', 'Largest phylum; jointed appendages; exoskeleton of chitin; open circulatory system; e.g., insects, crabs, spiders, Limulus (king crab — living fossil).'),
    _f('c11_4_10', 'Animal Kingdom', 'Characteristics of Mollusca.', 'Second largest phylum; soft body; mantle; radula (rasping organ); e.g., Pila (snail), Octopus, Loligo (squid), Sepia (cuttlefish).'),
    _f('c11_4_11', 'Animal Kingdom', 'Characteristics of Echinodermata.', 'Water vascular system; spiny skin; tube feet; endoskeleton of calcareous ossicles; regeneration ability; e.g., starfish, sea urchin, Holothuria (sea cucumber).'),
    _f('c11_4_12', 'Animal Kingdom', 'What is notochord?', 'A mesodermally derived rod-like structure present at least in embryonic stage; basis of phylum Chordata.'),
    _f('c11_4_13', 'Animal Kingdom', 'Differences between Urochordata and Cephalochordata.', 'Urochordata: notochord only in larval tail (e.g., Ascidia). Cephalochordata: notochord extends from head to tail throughout life (Amphioxus).'),
    _f('c11_4_14', 'Animal Kingdom', 'Classes of class Pisces.', 'Chondrichthyes (cartilaginous fish, e.g., Scoliodon/shark) and Osteichthyes (bony fish, e.g., Labeo/rohu, Hippocampus/seahorse).'),
    _f('c11_4_15', 'Animal Kingdom', 'Key feature of class Mammalia.', 'Presence of mammary glands; hair on body; warm-blooded; 4-chambered heart; direct development; e.g., Ornithorhynchus (platypus), Macropus (kangaroo), bats.'),
  ];

  static final _ch5 = <FlashcardModel>[
    _f('c11_5_1',  'Morphology of Flowering Plants', 'What is a tap root system vs fibrous root system?', 'Tap root: primary root from radical persists, dicots. Fibrous root: primary root short-lived, monocots; adventitious roots from stem.'),
    _f('c11_5_2',  'Morphology of Flowering Plants', 'Modifications of roots.', 'Storage (carrot, turnip), respiratory/pneumatophores (Rhizophora), support (prop roots, stilt roots in Maize, banyan), symbiosis (nodules in Rhizobium).'),
    _f('c11_5_3',  'Morphology of Flowering Plants', 'What are stem modifications? Examples.', 'Underground: rhizome (ginger), corm (Colocasia), tuber (potato), bulb (onion). Aerial: tendril (Cucurbita), thorn (Citrus), phylloclade (cactus).'),
    _f('c11_5_4',  'Morphology of Flowering Plants', 'Types of leaves based on venation.', 'Reticulate (dicots, e.g., peepal) and parallel (monocots, e.g., grass). Leaf types: simple vs compound.'),
    _f('c11_5_5',  'Morphology of Flowering Plants', 'What is phyllotaxy?', 'Pattern of leaf arrangement on stem: alternate (China rose), opposite (Calotropis), whorled (Alstonia).'),
    _f('c11_5_6',  'Morphology of Flowering Plants', 'Define inflorescence.', 'Arrangement of flowers on floral axis. Racemose (e.g., mustard) vs cymose (e.g., solanum). Special: Capitulum (sunflower), Verticillaster (tulsi).'),
    _f('c11_5_7',  'Morphology of Flowering Plants', 'Parts of a flower.', 'Calyx (sepals), Corolla (petals), Androecium (stamens), Gynoecium (pistil). Thalamus is the receptacle.'),
    _f('c11_5_8',  'Morphology of Flowering Plants', 'What is aestivation?', 'Arrangement of petals/sepals in bud: valvate (Calotropis), twisted (China rose), imbricate (Cassia), vexillary (Pea).'),
    _f('c11_5_9',  'Morphology of Flowering Plants', 'What is placentation?', 'Arrangement of ovules in ovary. Types: marginal (pea), axile (lemon), parietal (Argemone), basal (sunflower), free central (Primrose), superficial (Nymphaea).'),
    _f('c11_5_10', 'Morphology of Flowering Plants', 'Distinguish epigynous, perigynous, hypogynous.', 'Hypogynous: ovary superior (mustard). Perigynous: ovary half-inferior (plum, rose). Epigynous: ovary inferior (guava, apple).'),
    _f('c11_5_11', 'Morphology of Flowering Plants', 'Floral formula of Pea (Family Fabaceae).', '⊕ K₅ C₁₊₂₊₂ A(9)+1 G₁ — bisexual, zygomorphic, vexillary aestivation, superior ovary, monocarpellary.'),
    _f('c11_5_12', 'Morphology of Flowering Plants', 'Floral formula of mustard (Family Brassicaceae).', '⊕ K₂₊₂ C₄ A₂₊₄ G(2) — actinomorphic, tetradynamous stamens, superior ovary, bicarpellary syncarpous.'),
    _f('c11_5_13', 'Morphology of Flowering Plants', 'Characteristics of family Solanaceae (potato family).', 'Alternate simple leaves; cymose inflorescence; bisexual; 5-partite; epipetalous stamens; bilocular bicarpellary ovary with swollen placenta. E.g., tomato, potato, chilli.'),
    _f('c11_5_14', 'Morphology of Flowering Plants', 'Characteristics of Liliaceae (lily family).', 'Monocot; trimerous flowers; 6 perianth in 2 whorls; 6 epiphyllous stamens; superior tricarpellary syncarpous ovary; axile placentation. E.g., onion, garlic, aloe.'),
  ];

  static final _ch6 = <FlashcardModel>[
    _f('c11_6_1',  'Anatomy of Flowering Plants', 'Types of meristems based on position.', 'Apical (shoot/root tip), intercalary (base of internodes in grasses), lateral (vascular cambium, cork cambium).'),
    _f('c11_6_2',  'Anatomy of Flowering Plants', 'What is epidermis? Function.', 'Outermost layer of primary plant body; single layer; covered by cuticle; protects against water loss and pathogens.'),
    _f('c11_6_3',  'Anatomy of Flowering Plants', 'Types of simple permanent tissue.', 'Parenchyma (storage/support), Collenchyma (flexible support), Sclerenchyma (hard support, dead cells with lignin).'),
    _f('c11_6_4',  'Anatomy of Flowering Plants', 'Composition of xylem.', 'Tracheids (water conduction/support), vessels (water), xylem fibres (support), xylem parenchyma (food storage).'),
    _f('c11_6_5',  'Anatomy of Flowering Plants', 'Composition of phloem.', 'Sieve tube elements (food transport), companion cells (metabolically active), phloem fibres, phloem parenchyma.'),
    _f('c11_6_6',  'Anatomy of Flowering Plants', 'What is the dicot stem anatomy (distinguishing features)?', 'Epidermis → cortex → endodermis → pericycle → vascular bundles (open, conjoint, collateral, arranged in a ring) → pith.'),
    _f('c11_6_7',  'Anatomy of Flowering Plants', 'Difference: monocot vs dicot stem.', 'Monocot: vascular bundles scattered, no pith-cortex distinction, no cambium (closed bundles). Dicot: arranged in ring, cambium present (open bundles).'),
    _f('c11_6_8',  'Anatomy of Flowering Plants', 'What is secondary growth?', 'Increase in girth due to activity of vascular cambium (produces secondary xylem and phloem) and cork cambium.'),
    _f('c11_6_9',  'Anatomy of Flowering Plants', 'What is heartwood and sapwood?', 'Heartwood (duramen): dark, non-functional inner wood. Sapwood (alburnum): light, functional outer secondary xylem.'),
    _f('c11_6_10', 'Anatomy of Flowering Plants', 'What are annual rings?', 'Each year produces spring wood (wide lumened) and autumn wood (narrow lumened) — this alternation forms annual rings used to determine tree age.'),
    _f('c11_6_11', 'Anatomy of Flowering Plants', 'What is periderm? Components.', 'Replaces epidermis during secondary growth. Components: phellogen (cork cambium) → phellem (cork) outward + phelloderm inward.'),
    _f('c11_6_12', 'Anatomy of Flowering Plants', 'What are lenticels?', 'Pores in bark that allow gaseous exchange during secondary growth; replace stomata.'),
    _f('c11_6_13', 'Anatomy of Flowering Plants', 'Anatomy of a dicot leaf.', 'Epidermis (upper + lower with cuticle and stomata), mesophyll (palisade + spongy), vascular bundles with bundle sheath.'),
    _f('c11_6_14', 'Anatomy of Flowering Plants', 'What is a Casparian strip?', 'Suberized strip in endodermis of roots that forces water/ions into symplast, controlling what enters vascular tissue.'),
  ];

  static final _ch7 = <FlashcardModel>[
    _f('c11_7_1',  'Structural Organisation in Animals', 'Four types of animal tissues.', '1. Epithelial, 2. Connective, 3. Muscular, 4. Neural.'),
    _f('c11_7_2',  'Structural Organisation in Animals', 'Types of epithelial tissue.', 'Simple (squamous, cuboidal, columnar, ciliated, pseudostratified) and Compound (stratified, transitional).'),
    _f('c11_7_3',  'Structural Organisation in Animals', 'What are junctional complexes?', 'Specialised cell junctions: tight junctions (seal adjacent cells), adhering junctions (mechanical support), gap junctions (chemical communication).'),
    _f('c11_7_4',  'Structural Organisation in Animals', 'Types of connective tissue.', 'Loose (areolar, adipose), Dense (regular—tendons, irregular—skin dermis), Specialised (bone, cartilage, blood, lymph).'),
    _f('c11_7_5',  'Structural Organisation in Animals', 'Differences: bone vs cartilage.', 'Bone: hard matrix (calcium salts), Haversian system, osteocytes. Cartilage: firm but flexible matrix (chondroitin), chondrocytes in lacunae.'),
    _f('c11_7_6',  'Structural Organisation in Animals', 'Types of muscle tissue.', 'Skeletal (striated, voluntary), Smooth (unstriated, involuntary, visceral), Cardiac (striated, involuntary, intercalated discs).'),
    _f('c11_7_7',  'Structural Organisation in Animals', 'Structure of a neuron.', 'Cell body (cyton) + dendrites + axon (covered by myelin sheath). Synapse = junction between neurons.'),
    _f('c11_7_8',  'Structural Organisation in Animals', 'Earthworm — body wall layers.', 'Cuticle → epidermis → circular muscles → longitudinal muscles → coelomic epithelium (chloragogen cells).'),
    _f('c11_7_9',  'Structural Organisation in Animals', 'Excretion in earthworm.', 'By nephridia (segmental organs). Three types: septal, integumentary, pharyngeal nephridia.'),
    _f('c11_7_10', 'Structural Organisation in Animals', 'Cockroach — respiratory system.', 'Tracheal system; air enters through spiracles (10 pairs); tracheae branch into tracheoles reaching all cells.'),
    _f('c11_7_11', 'Structural Organisation in Animals', 'Blood in cockroach.', 'Haemolymph — colourless as it doesn\'t carry O₂/CO₂ (only nutrients and waste). Open circulatory system.'),
    _f('c11_7_12', 'Structural Organisation in Animals', 'Frog — special features.', 'Ectothermal; cutaneous respiration through moist skin; 3-chambered heart (2 auricles, 1 ventricle); buccal, pulmonary, and skin respiration.'),
  ];

  static final _ch8 = <FlashcardModel>[
    _f('c11_8_1',  'Cell: The Unit of Life', 'Who proposed the cell theory?', 'Schleiden (1838) and Schwann (1839). Virchow added "omnis cellula e cellula" (all cells arise from pre-existing cells) in 1855.'),
    _f('c11_8_2',  'Cell: The Unit of Life', 'Difference: prokaryote vs eukaryote.', 'Prokaryote: no membrane-bound nucleus, 70S ribosomes, no membrane-bound organelles. Eukaryote: true nucleus, 80S ribosomes, membrane-bound organelles.'),
    _f('c11_8_3',  'Cell: The Unit of Life', 'What is the fluid mosaic model?', 'Singer and Nicolson (1972): cell membrane is a fluid bilayer of phospholipids with proteins embedded (integral) or attached (peripheral). Cholesterol increases rigidity.'),
    _f('c11_8_4',  'Cell: The Unit of Life', 'Structure of the nucleus.', 'Nuclear envelope (2 membranes with pores) → nucleoplasm → chromatin (DNA + histone) → nucleolus (rRNA synthesis).'),
    _f('c11_8_5',  'Cell: The Unit of Life', 'Function of the endoplasmic reticulum.', 'RER: has ribosomes; involved in protein synthesis and transport. SER: no ribosomes; lipid/steroid synthesis, detoxification.'),
    _f('c11_8_6',  'Cell: The Unit of Life', 'What are Golgi bodies?', 'Stack of membrane-bound cisternae; cis face receives from ER, trans face releases secretory vesicles; involved in glycosylation and secretion.'),
    _f('c11_8_7',  'Cell: The Unit of Life', 'What are lysosomes?', 'Membrane-bound vesicles with hydrolytic enzymes; "suicide bags" — digest worn-out organelles (autophagy) and foreign material; formed by Golgi body.'),
    _f('c11_8_8',  'Cell: The Unit of Life', 'Structure of mitochondria.', 'Double membrane; inner membrane folds = cristae; matrix contains circular DNA, 70S ribosomes, enzymes for Krebs cycle; ATP synthesis on inner membrane (F₀F₁ complex).'),
    _f('c11_8_9',  'Cell: The Unit of Life', 'Structure of chloroplast.', 'Double membrane; thylakoids stacked into grana; stroma contains circular DNA, 70S ribosomes; light reactions in thylakoids, dark reactions in stroma.'),
    _f('c11_8_10', 'Cell: The Unit of Life', 'What are ribosomes? Types.', 'Non-membrane bound; site of protein synthesis. 80S (eukaryotes): 60S + 40S. 70S (prokaryotes, mitochondria, chloroplasts): 50S + 30S.'),
    _f('c11_8_11', 'Cell: The Unit of Life', 'What is a centrosome?', 'Contains two centrioles (at right angles); only in animal cells and lower plants; organises the spindle during cell division.'),
    _f('c11_8_12', 'Cell: The Unit of Life', 'What is a vacuole?', 'Membrane-bound space (tonoplast membrane); large in plant cells (central vacuole for turgidity); contractile vacuoles in protists for osmoregulation.'),
    _f('c11_8_13', 'Cell: The Unit of Life', 'What is the nuclear pore complex?', 'Protein channel through nuclear envelope; regulates exchange of RNA, proteins, and other molecules between nucleus and cytoplasm.'),
    _f('c11_8_14', 'Cell: The Unit of Life', 'What are microbodies?', 'Peroxisomes (contain oxidative enzymes, detoxify H₂O₂, β-oxidation of fatty acids) and glyoxysomes (plants, convert fat to sugar in seeds).'),
  ];

  static final _ch9 = <FlashcardModel>[
    _f('c11_9_1',  'Biomolecules', 'Primary vs secondary metabolites.', 'Primary: amino acids, sugars, nucleotides — essential for growth. Secondary: alkaloids, flavonoids, gums — ecological roles, not directly essential.'),
    _f('c11_9_2',  'Biomolecules', 'What is a peptide bond?', 'Covalent bond between –COOH of one amino acid and –NH₂ of next, with loss of water. Polypeptide = chain of amino acids linked by peptide bonds.'),
    _f('c11_9_3',  'Biomolecules', 'Protein structure levels.', 'Primary: amino acid sequence. Secondary: α-helix or β-pleated sheet (H-bonds). Tertiary: 3D folding. Quaternary: multiple polypeptide subunits.'),
    _f('c11_9_4',  'Biomolecules', 'What is an enzyme? Characteristics.', 'Biological catalyst; protein (except ribozymes); colloidal; specific; reusable; sensitive to pH and temperature; have active site.'),
    _f('c11_9_5',  'Biomolecules', 'What is Km (Michaelis constant)?', 'Substrate concentration at which enzyme activity is half-maximum. Low Km = high affinity for substrate.'),
    _f('c11_9_6',  'Biomolecules', 'Competitive vs non-competitive inhibition.', 'Competitive: inhibitor similar to substrate, blocks active site; Vmax unchanged, Km increases. Non-competitive: inhibitor binds allosteric site; Vmax decreases, Km unchanged.'),
    _f('c11_9_7',  'Biomolecules', 'Types of RNA.', 'mRNA (messenger — carries code), tRNA (transfer — brings amino acids), rRNA (ribosomal — structural component). hnRNA is precursor mRNA.'),
    _f('c11_9_8',  'Biomolecules', 'Differences DNA vs RNA.', 'DNA: deoxyribose, double-stranded, thymine, stable. RNA: ribose, usually single-stranded, uracil, less stable.'),
    _f('c11_9_9',  'Biomolecules', 'What is the Chargaff\'s rule?', 'In DNA: A = T and G = C (A+G = C+T, i.e., purines = pyrimidines).'),
    _f('c11_9_10', 'Biomolecules', 'What are saturated vs unsaturated fatty acids?', 'Saturated: no double bonds (e.g., palmitic acid); solid at room temp. Unsaturated: one or more double bonds (e.g., oleic acid); liquid at room temp.'),
    _f('c11_9_11', 'Biomolecules', 'What is a coenzyme?', 'Non-protein organic molecule required for enzyme activity. E.g., NAD⁺, FAD, Coenzyme A. If tightly bound = prosthetic group (e.g., haem in catalase).'),
    _f('c11_9_12', 'Biomolecules', 'What are nucleotides? Components.', 'Nitrogenous base + pentose sugar + phosphate group. Nucleoside = base + sugar. Adenine is a purine; cytosine is a pyrimidine.'),
  ];

  static final _ch10 = <FlashcardModel>[
    _f('c11_10_1',  'Cell Cycle and Cell Division', 'Phases of the cell cycle.', 'Interphase (G₁ → S → G₂) + M phase (mitosis). G₀ = quiescent stage (cells not dividing). S phase = DNA replication.'),
    _f('c11_10_2',  'Cell Cycle and Cell Division', 'What happens in G₁ phase?', 'Cell grows in size; synthesis of RNA and proteins; organelle duplication begins. DNA content = 2N (2C).'),
    _f('c11_10_3',  'Cell Cycle and Cell Division', 'Stages of mitosis.', 'Prophase → Metaphase → Anaphase → Telophase → Cytokinesis. Results in 2 genetically identical diploid cells.'),
    _f('c11_10_4',  'Cell Cycle and Cell Division', 'What is the significance of mitosis?', 'Growth, repair, and asexual reproduction; maintains chromosome number; produces identical daughter cells.'),
    _f('c11_10_5',  'Cell Cycle and Cell Division', 'Stages of meiosis.', 'Meiosis I (reductional): Prophase I (leptotene→zygotene→pachytene→diplotene→diakinesis), Metaphase I, Anaphase I, Telophase I. Meiosis II (equational, like mitosis). Result: 4 haploid cells.'),
    _f('c11_10_6',  'Cell Cycle and Cell Division', 'What is crossing over? When does it occur?', 'Exchange of segments between non-sister chromatids of homologous chromosomes at chiasmata; occurs during pachytene of Prophase I; increases genetic variability.'),
    _f('c11_10_7',  'Cell Cycle and Cell Division', 'Significance of meiosis.', 'Maintains chromosome number across generations; crossing over creates genetic variation; basis of sexual reproduction.'),
    _f('c11_10_8',  'Cell Cycle and Cell Division', 'What is the synaptonemal complex?', 'Protein structure holding homologous chromosomes together during zygotene and pachytene; facilitates crossing over.'),
    _f('c11_10_9',  'Cell Cycle and Cell Division', 'Difference between mitosis in plants vs animals.', 'Animals: centrioles organise spindle; cleavage furrow. Plants: no centrioles; phragmoplast forms cell plate.'),
    _f('c11_10_10', 'Cell Cycle and Cell Division', 'What is the kinetochore?', 'Protein complex on centromere; spindle fibres attach here during mitosis/meiosis to pull chromatids apart.'),
    _f('c11_10_11', 'Cell Cycle and Cell Division', 'What are cyclin-CDK complexes?', 'Cyclin (regulatory) + Cyclin-Dependent Kinase (CDK) drive transitions in the cell cycle (e.g., G₁/S, G₂/M checkpoints).'),
    _f('c11_10_12', 'Cell Cycle and Cell Division', 'What is amitosis?', 'Direct nuclear division without spindle formation; seen in amoeba, yeast, and some mammalian cells (not a normal process).'),
  ];

  // Chapters 11–22 (Class 11)
  static final _ch11 = _makeSimple('Transport in Plants', '11', [
    ['Imbibition', 'Adsorption of water by solid particles (e.g., seeds absorb water before germination). Pressure developed = imbibition pressure.'],
    ['Osmosis', 'Movement of water across semi-permeable membrane from higher water potential to lower water potential.'],
    ['Water potential (ψ)', 'ψ = ψₛ + ψₚ. Pure water ψ = 0; adding solutes lowers ψ; pressure increases ψ.'],
    ['Apoplast pathway', 'Movement of water through cell walls and intercellular spaces without crossing membranes; faster but stopped by Casparian strip.'],
    ['Symplast pathway', 'Movement through cytoplasm and plasmodesmata; slower but controlled.'],
    ['Transpiration', 'Loss of water as vapour from aerial parts. Stomatal (90–95%), cuticular, lenticular.'],
    ['Cohesion-tension theory', 'Accepted theory for water ascent: water molecules stick together (cohesion) and to xylem walls (adhesion); transpiration creates tension pulling water up.'],
    ['Translocation', 'Movement of organic solutes in phloem from source (leaves) to sink (roots, fruits). Pressure flow / mass flow hypothesis.'],
    ['Mass flow hypothesis', 'Münch: high pressure at source (loading sucrose → osmotic entry of water) drives flow toward sink with lower pressure.'],
    ['Mineral absorption', 'Passive (diffusion, channel proteins) and active transport (carrier proteins, energy/ATP needed against concentration gradient).'],
    ['Essential elements', 'Macro: N, P, K, Ca, Mg, S. Micro (trace): Fe, Mn, B, Zn, Cu, Mo, Cl, Ni. Criterion: deficiency produces symptoms, cannot be substituted.'],
    ['Guttation', 'Exudation of liquid water droplets from hydathodes at leaf margins; occurs when soil water is plentiful and transpiration is low (night/early morning).'],
  ]);

  static final _ch12 = _makeSimple('Mineral Nutrition', '11', [
    ['Nitrogen fixation', 'Conversion of N₂ to NH₃. Biological: by Rhizobium (symbiotic), Azotobacter, Anabaena (free-living). Industrial: Haber process.'],
    ['Nif gene', 'Nitrogenase gene; codes for nitrogenase enzyme which reduces N₂ to NH₃.'],
    ['Nitrification', 'Oxidation of NH₃ → NO₂⁻ → NO₃⁻ by Nitrosomonas and Nitrobacter (chemoautotrophs).'],
    ['Denitrification', 'Conversion of NO₃⁻ back to N₂ by Pseudomonas and Thiobacillus; removes nitrogen from soil.'],
    ['Ammonification', 'Decomposition of organic nitrogen (proteins) to NH₃ by decomposers.'],
    ['Hydroponics', 'Growing plants in nutrient solution without soil; used to study essential elements.'],
    ['Deficiency symptoms', 'N: chlorosis, stunted growth. P: dark green/purple leaves. K: tip-burn of leaves. Fe: interveinal chlorosis. Ca: death of growing tips.'],
    ['Nodule formation', 'Rhizobium in root nodules; leghaemoglobin (pink) provides anaerobic environment for nitrogenase which is O₂-sensitive.'],
    ['Nitrogen assimilation', 'NH₃ incorporated into organic compounds via GS-GOGAT pathway; produces glutamine and glutamate.'],
  ]);

  static final _ch13 = _makeSimple('Photosynthesis in Higher Plants', '11', [
    ['Overall equation', '6CO₂ + 12H₂O → C₆H₁₂O₆ + 6O₂ + 6H₂O (van Niel). Light-dependent + light-independent reactions.'],
    ['Chlorophyll a vs b', 'Chl-a: primary pigment (reaction centre), blue-green. Chl-b: accessory, yellow-green. Both absorb red and blue light.'],
    ['Z-scheme', 'Non-cyclic photophosphorylation: PS-II (P680) → electron transport → PS-I (P700) → NADPH. Net: O₂ evolved, NADPH and ATP formed.'],
    ['Cyclic photophosphorylation', 'Only PS-I involved; electrons cycled back; only ATP produced; no NADPH, no O₂. Operates under low CO₂.'],
    ['Calvin cycle (C3)', '3 turns fix 3CO₂; 9 ATP + 6 NADPH → 1 G3P (triose phosphate). CO₂ → RuBP (5C) + CO₂ → 2× PGA (3C) by RuBisCO.'],
    ['C4 pathway', 'Primary CO₂ acceptor = PEP (3C) → OAA (4C) in mesophyll cells by PEP-carboxylase. CO₂ released in bundle sheath cells to Calvin cycle. No photorespiration. E.g., maize, sugarcane.'],
    ['Photorespiration', 'RuBisCO acts as oxygenase; O₂ added to RuBP → phosphoglycolate (2C) → CO₂ released; occurs in C3 plants in high O₂/low CO₂.'],
    ['Photosystem II vs I', 'PS-II: P680, splits water (O₂ evolved), first in Z-scheme. PS-I: P700, reduces NADP⁺ to NADPH.'],
    ['Emerson enhancement effect', 'Photosynthesis rate is more when both red (far-red, 700nm) and far-red (680nm) are given simultaneously — shows 2 photosystems work together.'],
    ['Blackman\'s law of limiting factors', '"When a process is conditioned by more than one factor, its rate is limited by the factor nearest its minimum." CO₂ is often the limiting factor.'],
    ['ATP synthase (CF₀F₁)', 'Synthesises ATP using proton gradient across thylakoid membrane (chemiosmotic hypothesis by Peter Mitchell).'],
  ]);

  static final _ch14 = _makeSimple('Respiration in Plants', '11', [
    ['Glycolysis (EMP pathway)', 'Occurs in cytoplasm; 1 glucose → 2 pyruvate + 2 ATP (net) + 2 NADH. Does not require oxygen.'],
    ['Fermentation', 'Anaerobic respiration: pyruvate → ethanol + CO₂ (yeast) or lactic acid (muscle, some bacteria). Net 2 ATP.'],
    ['Krebs (TCA) cycle', 'Occurs in mitochondrial matrix; 2 acetyl CoA → 4CO₂ + 6NADH + 2FADH₂ + 2ATP (GTP). Enzyme: isocitrate dehydrogenase is key regulatory enzyme.'],
    ['ETC / Oxidative phosphorylation', 'Occurs in inner mitochondrial membrane; NADH → Complex I → CoQ → Complex III → Cyt c → Complex IV → O₂; drives ATP synthesis by chemiosmosis.'],
    ['ATP yield', 'Complete aerobic: ~36–38 ATP per glucose. Glycolysis: 2, Krebs: 2 GTP, ETC: ~32.'],
    ['Respiratory quotient (RQ)', 'RQ = CO₂ evolved / O₂ consumed. Carbohydrates = 1.0; fats < 1 (0.7); proteins ~0.9; organic acids > 1.'],
    ['Amphibolic pathway', 'Respiration is both catabolic and anabolic; intermediates (e.g., acetyl CoA, α-ketoglutarate) used for biosynthesis.'],
    ['Pasteur effect', 'O₂ suppresses anaerobic fermentation; named after Louis Pasteur.'],
  ]);

  static final _ch15 = _makeSimple('Plant Growth and Development', '11', [
    ['Plant growth characteristics', 'Localised meristems; open growth (indeterminate); arithmetic and geometric phases; exponential growth described by W = W₀ eʳᵗ.'],
    ['Phytohormones overview', 'Auxins (IAA — cell elongation), Gibberellins (GA — stem elongation, bolting), Cytokinins (cell division), ABA (stress hormone, "stress hormone", dormancy), Ethylene (ripening, epinasty).'],
    ['Auxin', 'IAA (indole-3-acetic acid); produced in shoot apex; promotes cell elongation (by loosening cell wall); responsible for phototropism and geotropism; Went demonstrated with oat coleoptile.'],
    ['Gibberellins', 'Promote stem elongation, leaf expansion, overcome seed/bud dormancy; bolting (rosette plants). First isolated from Gibberella fujikuroi (bakanae disease of rice).'],
    ['Cytokinins', 'Promote cell division; delay senescence (Richmond-Lang effect); promote lateral bud growth; synthesised where cell division is rapid (roots, fruits, seeds).'],
    ['ABA (Abscisic acid)', 'Stress hormone; causes stomatal closure; promotes dormancy and seed development; inhibits growth; antagonises gibberellins.'],
    ['Ethylene', 'Gas; promotes ripening, epinasty, senescence; breaks dormancy in peanut seeds; promotes root growth at low concentrations; used commercially as ethephon.'],
    ['Photoperiodism', 'Response of plants to relative duration of light and dark. SDP (short-day): night > critical length (e.g., Chrysanthemum). LDP: night < critical length (e.g., wheat). Day neutral: not affected (tomato).'],
    ['Vernalisation', 'Promotion of flowering by a cold treatment; prevents precocious flowering; e.g., winter wheat needs cold to flower the following season.'],
  ]);

  // Chapters 16–22 abbreviated
  static final _ch16 = _makeSimple('Digestion and Absorption', '11', [
    ['Parts of alimentary canal', 'Mouth → pharynx → oesophagus → stomach → small intestine (duodenum, jejunum, ileum) → large intestine (caecum, colon, rectum) → anus.'],
    ['Saliva', 'Salivary amylase (ptyalin) starts starch digestion; pH 6.8; lubricates food; lysozyme kills bacteria.'],
    ['Stomach secretions', 'HCl (kills bacteria, activates pepsinogen), pepsin (protein digestion), mucus (protects stomach wall), gastric lipase, intrinsic factor (Vit B12 absorption).'],
    ['Pancreatic juice', 'Contains trypsinogen, chymotrypsinogen, pancreatic amylase, pancreatic lipase, nucleases. Trypsinogen activated by enterokinase to trypsin.'],
    ['Bile', 'Produced by liver, stored in gall bladder; contains bile salts (emulsify fats), bile pigments (bilirubin, biliverdin — from Hb breakdown). No enzymes.'],
    ['Absorption', 'Nutrients absorbed in small intestine: glucose/amino acids via villi → blood capillaries → portal vein → liver. Fatty acids/glycerol → lacteals → lymph.'],
    ['Large intestine', 'Absorbs water, minerals, some vitamins; bacteria synthesise Vit K and B12; forms faeces.'],
    ['Disorders', 'Constipation, diarrhoea, jaundice (excess bilirubin), indigestion, vomiting (emesis).'],
  ]);

  static final _ch17 = _makeSimple('Breathing and Exchange of Gases', '11', [
    ['Lungs', 'Lobed (right: 3 lobes, left: 2 lobes); covered by pleural membranes; alveoli are functional units for gas exchange.'],
    ['Breathing mechanics', 'Inspiration: diaphragm contracts + external intercostals contract → thoracic volume ↑ → pressure ↓ → air in. Expiration: reverse.'],
    ['Pulmonary volumes', 'TV (500 mL), IRV (2500 mL), ERV (1000 mL), RV (1100 mL). TLC = IRV + TV + ERV + RV = 6000 mL. VC = IRV + TV + ERV = 4500 mL.'],
    ['Haemoglobin', 'Haem + globin; each Hb can carry 4 O₂; 97% O₂ transported as oxyHb; 3% dissolved in plasma.'],
    ['Oxygen dissociation curve', 'Sigmoidal; right shift (Bohr effect) in high CO₂/low pH/high temp/high 2,3-BPG → more O₂ released to tissues.'],
    ['CO₂ transport', '7% dissolved; 23% as carbaminoHb; 70% as bicarbonate (via carbonic anhydrase in RBC).'],
    ['Chloride shift', 'HCO₃⁻ exits RBC in exchange for Cl⁻ to maintain electrical neutrality; also called Hamburger\'s phenomenon.'],
    ['Disorders', 'Asthma (bronchospasm), emphysema (alveolar wall destruction, loss of elasticity), occupational lung diseases (silicosis, asbestosis).'],
  ]);

  static final _ch18 = _makeSimple('Body Fluids and Circulation', '11', [
    ['Blood composition', 'Plasma (55%): water, proteins, salts. Formed elements (45%): RBC (5 million/mm³), WBC (6000–8000/mm³), platelets (1.5–3.5 lakh/mm³).'],
    ['RBC', 'Biconcave, no nucleus, no mitochondria; 120-day lifespan; haemoglobin; produced in red bone marrow (haematopoiesis).'],
    ['WBC types', 'Granulocytes (neutrophils, eosinophils, basophils) and Agranulocytes (monocytes, lymphocytes). Neutrophils most common.'],
    ['Blood groups', 'ABO: A (A antigen + anti-B antibody), B (B + anti-A), AB (A+B, no antibody — universal recipient), O (no antigen, both antibodies — universal donor). Rh factor: +ve or -ve.'],
    ['Coagulation', 'Thrombin converts fibrinogen → fibrin; initiated by thromboplastin released from damaged tissue; Ca²⁺ and Vit K essential.'],
    ['Heart anatomy', 'Right side: deoxygenated blood (RA → RV → pulmonary artery). Left side: oxygenated (LA → LV → aorta). SAN (pacemaker), AVN, Bundle of His, Purkinje fibres.'],
    ['Cardiac cycle', 'Systole (0.3s) + Diastole (0.5s) = 0.8s; heart rate ~72/min; stroke volume ~70 mL; cardiac output = SV × HR ≈ 5 L/min.'],
    ['Blood pressure', 'Systolic ~120 mmHg, diastolic ~80 mmHg. Measured by sphygmomanometer. Hypertension: >140/90.'],
    ['Lymph', 'Colourless fluid derived from interstitial fluid; carried in lymph vessels → thoracic duct → blood; contains lymphocytes; transports fats (from lacteals).'],
  ]);

  static final _ch19 = _makeSimple('Excretory Products and their Elimination', '11', [
    ['Excretion types', 'Ammonotelism (aquatic, e.g., fish, aquatic amphibians); Ureotelism (semi-aquatic, e.g., mammals, frogs); Uricotelism (terrestrial, saves water — birds, reptiles, insects).'],
    ['Nephron structure', 'Bowman\'s capsule + glomerulus (Malpighian body) → PCT → Loop of Henle (descending + ascending) → DCT → collecting duct.'],
    ['GFR', 'Glomerular filtration rate ≈ 125 mL/min = 180 L/day. Filtrate forced by hydrostatic pressure; plasma proteins and blood cells not filtered.'],
    ['Tubular reabsorption', 'PCT: glucose, amino acids, 70% water, Na⁺ (active). Loop of Henle: creates medullary gradient (counter-current). DCT: Na⁺, water (ADH controlled). CD: water (ADH).'],
    ['ADH & Aldosterone', 'ADH (vasopressin): increases water reabsorption in CD (diabetes insipidus if absent). Aldosterone: increases Na⁺ reabsorption in DCT → water follows.'],
    ['JGA & Renin-Angiotensin', 'JGA senses low BP → renin → angiotensin I → ACE → angiotensin II → vasoconstriction + aldosterone release → Na⁺ retention → BP rises.'],
    ['Micturition reflex', 'Stretch receptors in bladder wall → signals → micturition centre → parasympathetic → detrusor contracts; internal sphincter relaxes; voluntary control of external sphincter.'],
    ['Disorders', 'Renal failure, kidney stones (oxalate/urate), glomerulonephritis, dialysis/haemodialysis.'],
  ]);

  static final _ch20 = _makeSimple('Locomotion and Movement', '11', [
    ['Types of movement', 'Ciliary (fallopian tubes, trachea), Flagellar (sperm, Euglena), Muscular (locomotion).'],
    ['Sliding filament theory', 'Actin (thin) filaments slide over myosin (thick) during contraction; H-zone and I-band decrease; A-band stays same; sarcomere shortens.'],
    ['Muscle contraction steps', 'Nerve impulse → ACh at NMJ → action potential → T-tubules → Ca²⁺ from SR → troponin-tropomyosin complex moves → actin-myosin cross bridges → ATP hydrolysis → contraction.'],
    ['Rigor mortis', 'Stiffening after death; ATP depleted so cross bridges can\'t detach; resolves as proteins decompose.'],
    ['Red vs White muscle', 'Red (slow twitch): more myoglobin, mitochondria, fatigue-resistant, aerobic. White (fast twitch): fewer mitochondria, anaerobic, fatigue quickly.'],
    ['Joints', 'Ball & socket (hip, shoulder), Hinge (elbow, knee), Pivot (atlas-axis), Gliding (carpals), Saddle (thumb base), Suture (skull).'],
    ['Bone disorders', 'Arthritis (joint inflammation), osteoporosis (low bone density), gout (uric acid crystals in joints), osteoarthritis vs rheumatoid arthritis.'],
    ['Axial skeleton', '80 bones: skull (29), vertebral column (26), ribs (24) + sternum = 80.'],
    ['Appendicular skeleton', '126 bones: pectoral girdle (4) + arms/hands (60) + pelvic girdle (2) + legs/feet (60).'],
  ]);

  static final _ch21 = _makeSimple('Neural Control and Coordination', '11', [
    ['Resting membrane potential', '-70 mV inside; maintained by Na⁺-K⁺ pump (3 Na⁺ out: 2 K⁺ in); K⁺ leaks out; more anions inside.'],
    ['Action potential', 'Depolarisation (Na⁺ rushes in → +30 mV) → Repolarisation (K⁺ rushes out) → Hyperpolarisation → return to rest. All-or-none law.'],
    ['Synapse', 'Axon terminal (presynaptic) → synaptic cleft → dendrite/soma (postsynaptic). Neurotransmitters (ACh, noradrenaline, dopamine) released by exocytosis.'],
    ['Divisions of NS', 'CNS (brain + spinal cord) + PNS (cranial + spinal nerves + ANS). ANS: sympathetic (fight/flight) + parasympathetic (rest/digest).'],
    ['Forebrain', 'Cerebrum (thinking, voluntary), thalamus (relay), hypothalamus (homeostasis, sleep, emotions, hunger, thirst, body temp, pituitary regulation).'],
    ['Hindbrain', 'Cerebellum (coordination, balance), pons (connects brain parts), medulla oblongata (controls heart rate, breathing, vomiting).'],
    ['Reflex arc', 'Receptor → afferent nerve → spinal cord (integration) → efferent nerve → effector. Faster than voluntary response.'],
    ['EEG', 'Records electrical activity of brain (electroencephalogram); α waves (relaxed), β waves (alert), δ waves (deep sleep), θ waves (drowsy).'],
  ]);

  static final _ch22 = _makeSimple('Chemical Coordination and Integration', '11', [
    ['Types of glands', 'Exocrine (duct-based, e.g., salivary), Endocrine (ductless, secrete hormones directly into blood), Mixed (pancreas, gonads).'],
    ['Hypothalamus-pituitary axis', 'Hypothalamus: releasing (RH) and inhibitory hormones (IH) → regulate anterior pituitary. Posterior pituitary: stores/releases ADH and oxytocin (made in hypothalamus).'],
    ['Anterior pituitary hormones', 'GH (growth), TSH (thyroid), ACTH (adrenal cortex), FSH/LH (gonads), PRL (prolactin/lactation), MSH (melanocyte stimulation).'],
    ['Thyroid hormones', 'T₃ (triiodothyronine) and T₄ (thyroxine); require iodine; increase BMR, heart rate, protein synthesis. Calcitonin: lowers blood Ca²⁺.'],
    ['Adrenal gland', 'Cortex: mineralocorticoids (aldosterone, Na⁺ retention), glucocorticoids (cortisol, stress, anti-inflammatory), sex corticoids. Medulla: adrenaline and noradrenaline (fight/flight).'],
    ['Pancreatic hormones', 'Insulin (β-cells): lowers blood glucose. Glucagon (α-cells): raises blood glucose. Somatostatin (δ-cells): inhibits both. Diabetes mellitus: Type 1 (no insulin), Type 2 (insulin resistance).'],
    ['Calcium regulation', 'PTH (parathyroid) raises blood Ca²⁺ (stimulates osteoclasts, kidney reabsorption). Calcitonin lowers Ca²⁺.'],
    ['Pineal gland', 'Secretes melatonin; regulates circadian rhythm and photoperiodism (seasonal reproduction).'],
    ['Prostaglandins', 'Paracrine hormones (act locally); diverse effects: inflammation, platelet aggregation, smooth muscle contraction; not stored.'],
  ]);

  // ─── CLASS 12 ───────────────────────────────────────────────

  static final _c12_1 = _makeSimple('Reproduction in Organisms', '12', [
    ['Asexual reproduction modes', 'Binary fission (Amoeba), budding (Hydra, yeast), fragmentation (Spirogyra), spore formation, vegetative propagation (plants).'],
    ['Sexual reproduction events', '1. Pre-fertilisation (gametogenesis + gamete transfer). 2. Fertilisation. 3. Post-fertilisation (zygote → embryo → new organism).'],
    ['External vs internal fertilisation', 'External (water needed, e.g., frogs, fish) — large number of gametes. Internal (e.g., reptiles, birds, mammals) — few gametes, better protection.'],
    ['Oestrus vs Menstrual cycle', 'Oestrus cycle: non-primate mammals, no menstruation. Menstrual cycle: primates including humans.'],
    ['Juvenile / Vegetative phase', 'Pre-reproductive phase; organisms grow to maturity; duration varies: mouse 6 weeks, human 12–14 years, bamboo 50+ years.'],
    ['Senescent phase', 'Post-reproductive phase; metabolic changes; ultimately leads to death.'],
  ]);

  static final _c12_2 = _makeSimple('Sexual Reproduction in Flowering Plants', '12', [
    ['Stamen structure', 'Filament + anther (2 lobes, 4 microsporangia). Microsporangia produce microspores (pollen).'],
    ['Pollen grain structure', 'Exine (sporopollenin, resistant) with apertures (colpi/pores) + intine (cellulose). Vegetative + generative cells inside.'],
    ['Megasporogenesis', 'MMC (2n) → meiosis → 4 megaspores; 3 degenerate; 1 functional → 8-nucleate embryo sac (polygornum type).'],
    ['Embryo sac (7-celled, 8-nucleate)', '3 antipodals, 1 central cell (2 polar nuclei), 1 egg cell, 2 synergids (with filiform apparatus).'],
    ['Double fertilisation', 'Sperm 1 + egg → zygote (2n). Sperm 2 + 2 polar nuclei → Primary endosperm nucleus (3n, PEN). Unique to angiosperms.'],
    ['Endosperm types', 'Nuclear (most common), Cellular (Datura), Helobial (monocots). Provides nutrition to embryo.'],
    ['Seed structure (dicot)', 'Seed coat + endosperm + embryo (radicle + plumule + 2 cotyledons). Coleorhiza (radicle sheath) and coleoptile (plumule sheath) in monocots.'],
    ['Apomixis', 'Seed formation without fertilisation; reduces genetic variation. E.g., Taraxacum (dandelion), citrus (polyembryony).'],
    ['Polyembryony', 'Presence of more than one embryo in a seed. E.g., Citrus — one sexual + multiple nucellar embryos.'],
    ['Self-incompatibility', 'Prevents self-fertilisation; pollen recognised by S-gene products; pollen tube growth inhibited if same S-allele.'],
    ['Pollination types', 'Self (autogamy, geitonogamy) vs cross pollination (xenogamy) by wind (anemophily), water (hydrophily), insects (entomophily), animals (zoophily).'],
  ]);

  static final _c12_3 = _makeSimple('Human Reproduction', '12', [
    ['Male reproductive organs', 'Testes (seminiferous tubules + Leydig cells), epididymis, vas deferens, seminal vesicle, prostate, bulbourethral gland, penis.'],
    ['Spermatogenesis', 'Spermatogonia (2n) → primary spermatocyte → meiosis I → secondary spermatocyte → meiosis II → spermatids → spermatozoa (by spermiogenesis).'],
    ['Sperm structure', 'Head (acrosome + nucleus), neck, middle piece (mitochondrial sheath for energy), tail (flagellum).'],
    ['Female reproductive organs', 'Ovaries, fallopian tubes (oviducts), uterus (fundus, body, cervix), vagina. Uterus has perimetrium, myometrium, endometrium.'],
    ['Oogenesis', 'Oogonia → primary oocyte (arrested at Prophase I) → meiosis I (after LH surge) → secondary oocyte + 1st polar body → meiosis II → ovum + 2nd polar body.'],
    ['Menstrual cycle', '28 days: Menstrual (1–5), Proliferative/follicular (6–13), Ovulatory (14), Secretory/luteal (15–28). Controlled by FSH, LH, estrogen, progesterone.'],
    ['Fertilisation', 'In ampulla of fallopian tube; acrosome reaction releases enzymes; cortical reaction prevents polyspermy; syngamy forms zygote.'],
    ['Implantation', 'Blastocyst implants in uterine endometrium ~7 days after fertilisation; trophoblast fingers into endometrium.'],
    ['Placenta', 'Formed from trophoblast + endometrium; produces hCG (maintains corpus luteum), estrogen, progesterone; provides nutrition and gas exchange.'],
    ['Parturition', 'Triggered by oxytocin (positive feedback); estrogen/relaxin soften cervix; uterine contractions expel foetus. Full term ≈ 280 days.'],
    ['Colostrum', 'First milk secreted by mammary glands post-partum; rich in IgA antibodies, vitamins, proteins; yellowish.'],
  ]);

  static final _c12_4 = _makeSimple('Reproductive Health', '12', [
    ['STDs / STIs', 'Gonorrhoea (Neisseria), Syphilis (Treponema), Chlamydiosis, Genital herpes (HSV-2), Trichomoniasis, Hepatitis B, AIDS (HIV).'],
    ['Contraception methods', 'Natural (periodic abstinence, coitus interruptus, lactational amenorrhoea). Barrier (condom, diaphragm). IUD (Cu-T, LNG-IUS). Oral pills. Injectable. Implants. Surgical (vasectomy, tubectomy).'],
    ['IUD mechanisms', 'Cu-IUD: spermicidal Cu ions. Hormonal IUD (LNG): thickens cervical mucus + inhibits ovulation. Non-medicated IUD: creates inhospitable environment.'],
    ['Emergency contraception', 'Used within 72 hours (e.g., iPill). High-dose progestins prevent fertilisation/implantation.'],
    ['MTP (Medical Termination of Pregnancy)', 'Legal in India up to 20 weeks (extended to 24 for special cases); performed by registered medical practitioners.'],
    ['Infertility causes & treatment', 'Male: oligospermia, blocked vas, immotile sperm. Female: anovulation, tubal blockage, PCOS. IVF-ET (test tube baby), ZIFT, GIFT, IUI, ICSI, surrogacy.'],
    ['ART techniques', 'IVF: egg + sperm combined in lab → embryo transfer. ZIFT: zygote into fallopian tube. GIFT: gametes into tube. IUI: sperm directly into uterus.'],
  ]);

  static final _c12_5 = _makeSimple('Principles of Inheritance and Variation', '12', [
    ['Mendel\'s laws', 'Law of Dominance, Law of Segregation (purity of gametes), Law of Independent Assortment (only for genes on different chromosomes).'],
    ['Monohybrid cross', 'Tall × Dwarf → all Tall (F1). F1 × F1 → 3 Tall: 1 Dwarf (F2). Phenotypic ratio 3:1, Genotypic ratio 1:2:1.'],
    ['Dihybrid cross', 'RrYy × RrYy → 9 Round Yellow : 3 Round Green : 3 Wrinkled Yellow : 1 Wrinkled Green (9:3:3:1).'],
    ['Incomplete dominance', 'Neither allele completely dominates; F1 is intermediate. E.g., red × white Mirabilis → pink. F2 = 1 red : 2 pink : 1 white.'],
    ['Codominance', 'Both alleles express simultaneously. E.g., ABO blood group — AB has both A and B antigens (Iᴬ and Iᴮ codominant).'],
    ['Multiple alleles', 'ABO blood group: Iᴬ, Iᴮ, i. Iᴬ and Iᴮ codominant; both dominant over i.'],
    ['Linkage', 'Genes on same chromosome tend to be inherited together; reduces recombination; Morgan studied in Drosophila.'],
    ['Chromosomal theory', 'Sutton and Boveri (1902): genes are on chromosomes; explains Mendel\'s laws cytologically.'],
    ['Sex determination', 'XX-XY in humans (mammals); ZZ-ZW in birds (female heterogametic); XO in grasshopper; haplodiploid in Hymenoptera (bees).'],
    ['Sex-linked inheritance', 'Haemophilia A (F8 gene, Xhᴬ), Colour blindness (OPN1LW/MW, Xᶜ): both X-linked recessive; express in males with one copy; females need two copies to express.'],
    ['Mutation', 'Change in DNA sequence. Gene mutation (point, frameshift), chromosomal mutation (deletion, duplication, inversion, translocation). Mutagenic agents: UV, X-rays, chemicals.'],
    ['Chromosomal disorders', 'Down syndrome (trisomy 21, 47 chromosomes). Turner (45,XO). Klinefelter (47,XXY). Edwards (trisomy 18). Patau (trisomy 13).'],
  ]);

  static final _c12_6 = _makeSimple('Molecular Basis of Inheritance', '12', [
    ['DNA double helix (Watson-Crick, 1953)', 'Two antiparallel strands; right-handed; base pairs: A=T (2 H-bonds), G≡C (3 H-bonds); one turn = 10 bp = 3.4 nm; width 2 nm.'],
    ['DNA replication', 'Semi-conservative (Meselson-Stahl, 1958); bidirectional; at replication fork; helicase unwinds, primase adds RNA primer, DNA pol III elongates 5\'→3\', DNA pol I removes primer, ligase joins.'],
    ['Central dogma', 'DNA → (transcription) → RNA → (translation) → Protein. Reverse transcription possible (retroviruses). Crick, 1958.'],
    ['Transcription', 'Template strand read 3\'→5\'; RNA synthesised 5\'→3\'; rRNA from nucleolus; mRNA has exons + introns; splicing removes introns; capping + polyadenylation.'],
    ['Translation', 'mRNA + ribosome + tRNA (with amino acid). Start codon AUG (Met); stop codons UAA, UAG, UGA. Peptide bond formation on ribosome.'],
    ['Genetic code features', '64 codons (61 sense + 3 stop); triplet, non-overlapping, comma-less, degenerate (multiple codons for same AA, e.g., Leu=6), unambiguous, universal (except mitochondria).'],
    ['Lac operon (Jacob-Monod)', 'Negative inducible operon in E. coli. In absence of lactose: repressor binds operator → genes off. Lactose (inducer) → repressor removed → structural genes (lacZ, lacY, lacA) on.'],
    ['Chromatin packing', 'DNA → nucleosome (200 bp DNA + histone octamer [2×H2A, H2B, H3, H4] + H1) → 30 nm fibre → loops → chromosome.'],
    ['HGP (Human Genome Project)', 'Completed 2003; 3164.7 Mb; ~30,000 genes; 99.9% identical between humans; less than 2% encodes proteins; goals: map all genes, sequence DNA.'],
    ['DNA fingerprinting (Alec Jeffreys)', 'Uses VNTRs/STRs (variable number tandem repeats); probe hybridises; individual-specific pattern; used in forensics, paternity tests.'],
  ]);

  static final _c12_7 = _makeSimple('Evolution', '12', [
    ['Origin of life (Oparin-Haldane)', 'Chemical evolution: simple molecules → organic molecules (primordial soup) → complex molecules → proto-cells → living cells.'],
    ['Miller-Urey experiment (1953)', 'Electric spark in CH₄, NH₃, H₂, H₂O → amino acids and organic compounds. Supported Oparin-Haldane hypothesis.'],
    ['Lamarck (1809)', '"Inheritance of acquired characters" — use and disuse; later disproved.'],
    ['Darwin\'s natural selection', '1. Overproduction of offspring. 2. Heritable variation. 3. Struggle for existence. 4. Survival of fittest (natural selection). 5. New species over time.'],
    ['Hugo de Vries mutation theory', 'Evolution by sudden large changes (mutations), not gradual selection; studied Oenothera lamarckiana (evening primrose).'],
    ['Modern Synthetic Theory', 'Neo-Darwinism: combines Darwin\'s natural selection + Mendelian genetics + population genetics (Hardy-Weinberg). Evolution is change in allele frequencies.'],
    ['Hardy-Weinberg equilibrium', 'p² + 2pq + q² = 1; allele frequencies constant in absence of: mutation, gene flow, genetic drift, non-random mating, natural selection.'],
    ['Genetic drift', 'Random change in allele frequency in small populations. Bottleneck effect (disaster reduces population) and Founder effect (small group colonises new area).'],
    ['Adaptive radiation', 'Evolution of diverse forms from a common ancestor; e.g., Darwin\'s finches in Galápagos; marsupials in Australia.'],
    ['Convergent evolution', 'Similar features in unrelated species due to similar environment; e.g., wings in birds and bats (analogous organs).'],
    ['Homologous vs Analogous organs', 'Homologous: same origin/structure, different function (e.g., forelimbs of whale, bat, human — divergent evolution). Analogous: different origin, similar function (convergent).'],
    ['Human evolution', 'Dryopithecus → Ramapithecus → Australopithecus (Lucy) → Homo habilis → H. erectus → H. neanderthalensis → H. sapiens (~100,000 ya); "Out of Africa" theory.'],
  ]);

  static final _c12_8 = _makeSimple('Human Health and Disease', '12', [
    ['Immunity types', 'Innate (non-specific: skin, mucus, tears, phagocytes) vs Acquired (specific: B-cells for humoral, T-cells for cell-mediated). Active vs Passive.'],
    ['Active vs Passive immunity', 'Active: body produces own antibodies (vaccination or actual infection); long-lasting. Passive: ready-made antibodies given (e.g., anti-tetanus serum, mother\'s colostrum); short-lived.'],
    ['Antibody structure', 'Y-shaped immunoglobulin; 4 chains (2 heavy + 2 light); variable region = antigen-binding site; constant region determines class (IgG, IgM, IgA, IgE, IgD).'],
    ['Vaccines', 'Introduce weakened/killed pathogen or its proteins; stimulate memory cells; Edward Jenner — smallpox vaccine; BCG (TB), OPV (polio), MMR.'],
    ['Malaria (Plasmodium)', '4 spp.: P. vivax (benign tertian), P. falciparum (malignant, most dangerous), P. malariae (quartan), P. ovale. Vector: female Anopheles. Cycles in RBCs cause fever.'],
    ['AIDS (HIV)', 'HIV infects helper T-cells (CD4+) → T-cell count drops → immunodeficiency. Transmitted via blood, unprotected sex, mother-to-child. ELISA test. ART (antiretroviral therapy) controls.'],
    ['Cancer', 'Uncontrolled cell division. Proto-oncogenes → oncogenes (activated by carcinogens/mutation). Tumour suppressor genes (p53) lose function. Types: carcinoma, sarcoma, lymphoma, leukaemia.'],
    ['Allergy (Type I hypersensitivity)', 'Re-exposure to allergen → IgE (on mast cells) → histamine + serotonin release → symptoms. Treated with antihistamines, adrenaline.'],
    ['Drug/Alcohol abuse', 'Opioids (heroin/smack) — bind μ-receptors; cannabinoids (marijuana, hashish) — CB receptors; cocaine — blocks dopamine reuptake; sedatives/barbiturates; alcohol — depressant.'],
  ]);

  static final _c12_9 = _makeSimple('Strategies for Enhancement in Food Production', '12', [
    ['Animal husbandry goals', 'Improve breeds for milk, meat, egg production. Methods: selective breeding, artificial insemination, MOET, embryo transfer.'],
    ['MOET (Multiple Ovulation Embryo Transfer)', 'Superovulation with FSH → mate/AI → flush embryos → transfer to surrogates; increases progeny from superior cow.'],
    ['Plant breeding steps', '1. Collection of variability (germplasm collection). 2. Evaluation/selection. 3. Hybridisation. 4. Selection of superior hybrids. 5. Testing/release.'],
    ['Mutation breeding', 'Expose seeds/pollen to mutagens (radiation, chemicals); useful mutations selected. E.g., Mung bean (Pusa Vishal) resistant to yellow mosaic virus by mutation breeding.'],
    ['Polyploidy breeding', 'Colchicine (inhibits spindle) induces polyploidy; polyploids often have larger size; e.g., triploid watermelons (seedless).'],
    ['Hybrid vigour (Heterosis)', 'F1 hybrid superior to parents; due to heterozygosity; used in wheat, rice, maize, sunflower.'],
    ['Bio-fortification', 'Breeding crops with higher nutrients: Golden Rice (β-carotene/Vit A), Atlas 66 wheat (higher protein), Protina/Shakti maize (Lys + Trp).'],
    ['SCP (Single Cell Protein)', 'Protein from microbial biomass: Spirulina (alga), Methylophilus methylotrophus (bacterium); alternative protein source.'],
    ['Tissue culture / Somaclonal variation', 'Totipotency; micropropagation; somatic hybrids by protoplast fusion; somaclonal variation can be exploited for new varieties.'],
  ]);

  static final _c12_10 = _makeSimple('Microbes in Human Welfare', '12', [
    ['Microbes in fermentation', 'Lactobacillus (curd/yogurt), Saccharomyces cerevisiae (bread, beer), Aspergillus niger (citric acid), Acetobacter (acetic acid/vinegar), Clostridium (butanol).'],
    ['Antibiotics', 'Penicillin from Penicillium notatum (Fleming 1928); first antibiotic. Streptomycin (Streptomyces griseus); Chloramphenicol; Erythromycin; Tetracycline.'],
    ['Biogas', 'Methane-rich gas; produced by methanogenic archaea (Methanobacterium) in anaerobic conditions; KVIC designed biogas plants; slurry used as fertiliser.'],
    ['Bioremediation', 'Microbes clean up pollutants: oil spill bacteria, heavy metal bioleaching, Pseudomonas putida (degrades plastics/solvents), Thiobacillus (leaches metals).'],
    ['Sewage treatment', 'Primary: screening + sedimentation (BOD reduction ~30%). Secondary (biological): aeration tank (bacteria oxidise organic matter) → settling → effluent with low BOD. Sludge → biogas.'],
    ['BOD (Biological Oxygen Demand)', 'Oxygen needed by bacteria to decompose organic matter; indicator of water pollution. High BOD = highly polluted.'],
    ['Mycorrhiza in agriculture', 'Fungal symbiosis with roots; increases phosphate absorption; drought tolerance; reduces need for fertiliser.'],
    ['Biofertilisers', 'Rhizobium (legume root nodules), Azotobacter/Azospirillum (free-living N-fixers), cyanobacteria (paddy fields), mycorrhiza, Azolla (water fern + Anabaena — rice fields).'],
  ]);

  static final _c12_11 = _makeSimple('Biotechnology: Principles and Processes', '12', [
    ['Recombinant DNA technology steps', '1. Restriction enzyme cuts DNA. 2. Ligation into vector. 3. Transformation. 4. Selection/screening. 5. Cloning. 6. Expression.'],
    ['Restriction enzymes', 'Molecular scissors; cut ds-DNA at specific palindromic sequences (4-6 bp); produce sticky ends (cohesive) or blunt ends. EcoRI cuts G↓AATTC.'],
    ['Vectors', 'Carry foreign DNA into host. Plasmids (pBR322 — 2 antibiotic resistance genes for selection), bacteriophages (λ), cosmids, BAC, YAC, baculovirus.'],
    ['pBR322', 'First artificially constructed plasmid; ori, two antibiotic resistance genes (ampR, tetR); multiple restriction sites; insertional inactivation for selection.'],
    ['PCR (Polymerase Chain Reaction)', 'Amplifies specific DNA sequences. 3 steps: Denaturation (94°C) → Annealing (primers, 50–60°C) → Extension (Taq polymerase, 72°C). Exponential amplification (2ⁿ copies).'],
    ['Gel electrophoresis', 'Separates DNA/RNA/proteins by size through agarose/polyacrylamide gel in electric field. Smaller fragments migrate farther.'],
    ['Bioreactor', 'Large vessels for microbial production of protein; types: simple stirred tank, sparged stirred tank. Provide optimal conditions for culture.'],
    ['Downstream processing', 'After biosynthesis: separation, purification, formulation of product. Includes filtration, centrifugation, chromatography.'],
    ['cDNA library', 'Made from mRNA (reverse transcriptase → cDNA); represents only expressed genes; used for eukaryotic gene expression in bacteria.'],
  ]);

  static final _c12_12 = _makeSimple('Biotechnology and its Applications', '12', [
    ['Bt cotton', 'Contains Cry genes from Bacillus thuringiensis; Cry1Ac and Cry2Ab toxic to bollworm. Bt toxin (protoxin) activated in insect gut → pores → insect death.'],
    ['Golden Rice', 'Transgenic rice with daffodil β-carotene biosynthesis genes (Psy + Crt) + lycopene cyclase; produces β-carotene (pro-Vitamin A); addresses Vit A deficiency.'],
    ['Flavr Savr tomato', 'First GM food; antisense RNA for polygalacturonase enzyme → delayed ripening; approved in USA 1994 but later withdrawn.'],
    ['Insulin production', 'Eli Lilly (1982): human insulin (Humulin) from recombinant E. coli; A-chain and B-chain produced separately in E. coli, then combined with S-S bonds.'],
    ['Gene therapy', 'Introduces functional gene into cells with defective gene. First used for ADA (adenosine deaminase) deficiency (SCID); ex vivo gene therapy via retroviral vector.'],
    ['RNAi (RNA interference)', 'dsRNA silences complementary mRNA; RISC complex; used to control parasites (Meloidogyne — root-knot nematode in tobacco, plants produce ds-RNA).'],
    ['Molecular diagnostics', 'PCR for HIV (detect when antibody level low), ELISA (antigen-antibody), DNA probes/Southern blotting, microarrays.'],
    ['ELISA', 'Enzyme-Linked ImmunoSorbent Assay; detects antigen or antibody using enzyme-labelled antibody; colour change = positive result.'],
    ['Patents and biopiracy', 'Biopiracy: use of bio-resources without authorisation. India-specific examples: basmati rice (RiceTec), neem (EPO patent granted then revoked), haldi (turmeric patent revoked).'],
  ]);

  static final _c12_13 = _makeSimple('Organisms and Populations', '12', [
    ['Abiotic factors', 'Temperature, light, water, soil composition. Eurythermal (wide temp range) vs stenothermal. Euryhaline vs stenohaline.'],
    ['Adaptations', 'Structural (thick fur in arctic), physiological (ADH in desert animals), behavioural (burrowing). Allen\'s rule: ears larger in warm climates. Bergmann\'s rule: body size larger in cold.'],
    ['Population attributes', 'Birth rate, death rate, sex ratio, age structure (young, reproductive, old), population density.'],
    ['Population growth models', 'Exponential: dN/dt = rN (unlimited resources). Logistic: dN/dt = rN(K-N)/K; S-shaped/sigmoid; K = carrying capacity; J-curve vs S-curve.'],
    ['Life history traits', 'r-strategists: high growth rate, small body, many offspring, little parental care (e.g., insects). K-strategists: slow growth, large body, few offspring, much parental care (e.g., elephants).'],
    ['Population interactions', 'Mutualism (+/+), Commensalism (+/0), Amensalism (–/0), Predation (+/–), Competition (–/–), Parasitism (+/–).'],
    ['Competition', 'Interspecific: between species (Gause\'s competitive exclusion principle: 2 species competing for same resource → one excluded). Intraspecific: within species.'],
    ['Predation', 'Prey-predator oscillations (Lotka-Volterra). Adaptations: cryptic colouration, mimicry, chemical toxins (Monarch butterfly).'],
    ['Symbiosis examples', 'Lichens (algae + fungi). Mycorrhiza. Rhizobium-legume. Sea anemone-clownfish. Cleaner fish.'],
  ]);

  static final _c12_14 = _makeSimple('Ecosystem', '12', [
    ['Ecosystem components', 'Biotic (producers, consumers, decomposers) + Abiotic (light, temp, water, nutrients). Types: terrestrial, aquatic, artificial.'],
    ['Trophic levels', 'Producers (T1) → Primary consumers (T2) → Secondary consumers (T3) → Tertiary consumers (T4).'],
    ['Energy flow: 10% law (Lindemann)', 'Only ~10% of energy transferred between trophic levels; rest lost as heat. Basis for short food chains.'],
    ['Primary productivity', 'GPP (Gross Primary Productivity) = total photosynthesis. NPP = GPP – R (respiration). NPP available for consumers.'],
    ['Secondary productivity', 'Rate of formation of new organic matter by consumers (heterotrophs).'],
    ['Decomposition', 'Detritivores fragment detritus → bacteria/fungi mineralise → humus (dark, resistant organic matter) → nutrient release.'],
    ['Ecological pyramids', 'Pyramid of number, biomass, or energy. Energy pyramid always upright. Biomass pyramid inverted in ocean (phytoplankton < zooplankton). Number pyramid inverted in parasite ecosystem.'],
    ['Carbon cycle', 'CO₂ fixation (photosynthesis), released by respiration, decomposition, combustion. Sink: deep ocean, forests. About 4×10¹³ kg CO₂ fixed annually.'],
    ['Nitrogen cycle', 'Fixation (Rhizobium, lightning) → nitrification → assimilation → ammonification → denitrification (returns to atmosphere).'],
    ['Succession', 'Orderly change in community composition; primary (bare rock → climax) vs secondary (disturbed land → climax). Pioneer → intermediate → climax community.'],
    ['Ecosystem services', 'Provisioning (food, water, fiber), Regulating (climate, flood control, disease), Cultural (recreation, spiritual), Supporting (nutrient cycling, O₂ production). Value estimated >\$33 trillion/year.'],
  ]);

  static final _c12_15 = _makeSimple('Biodiversity and Conservation', '12', [
    ['Levels of biodiversity', 'Genetic (within species), Species (between species), Ecological (between ecosystems).'],
    ['India\'s biodiversity stats', '~45,000 plant species (7% of world flora), ~91,000 animal species (6.5% of world); 2 biodiversity hotspots: Western Ghats + Himalayas.'],
    ['IUCN categories', 'Extinct, Extinct in wild, Critically endangered, Endangered, Vulnerable, Near threatened, Least concern, Data deficient.'],
    ['Rivet popper hypothesis (Paul Ehrlich)', 'Like rivets in an airplane — losing one may not cause crash immediately, but continued loss eventually leads to catastrophic failure; illustrates ecosystem function loss.'],
    ['Causes of biodiversity loss (4 E\'s)', 'Extinction by: Habitat loss/fragmentation (main), Overexploitation, Exotic species invasion, Co-extinctions.'],
    ['Hotspots', '34 globally; characterised by ≥1500 endemic vascular plant species AND lost ≥70% original habitat; India has Western Ghats-Sri Lanka and Indo-Burma and Himalaya hotspots.'],
    ['In-situ conservation', 'Protected areas: National Parks (no human activity), Wildlife Sanctuaries (some human activity allowed), Biosphere Reserves (core + buffer + transition zones). E.g., Kaziranga, Nilgiris BR.'],
    ['Ex-situ conservation', 'Zoos, botanical gardens, seed banks (Svalbard, Norway — 850,000 accessions), cryopreservation, culture collections, gene libraries.'],
    ['Sacred groves', 'Forest patches protected by tribal communities due to religious beliefs; often harbour rare and endemic species; found in Meghalaya, Rajasthan, Western Ghats.'],
    ['Convention on Biodiversity (CBD)', 'Rio Summit 1992; addresses conservation, sustainable use, fair sharing of genetic resources. CITES regulates wildlife trade.'],
  ]);

  static final _c12_16 = _makeSimple('Environmental Issues', '12', [
    ['Greenhouse gases', 'CO₂ (main), CH₄, N₂O, CFCs, O₃. Greenhouse effect: gases trap reflected IR radiation → global warming. Global surface temp risen ~0.6°C in 20th century.'],
    ['Ozone depletion', 'CFC (chlorofluorocarbons) → Cl radicals → catalytically destroy O₃. Antarctic ozone hole. Montreal Protocol (1987) phased out CFCs. UV-B increases → skin cancer, cataract, affects phytoplankton.'],
    ['Acid rain', 'SO₂ + NO₂ from combustion → H₂SO₄ + HNO₃; pH < 5.6 damages forests, marble buildings (marble cancer), aquatic life.'],
    ['Eutrophication', 'Excessive nutrient (N, P) input → algal bloom → O₂ depletion (BOD rises) → death of aquatic organisms. Cultural eutrophication from sewage and agricultural runoff.'],
    ['Biomagnification', 'Concentration of toxin increases at each trophic level. DDT in food chain: phytoplankton (0.003 ppm) → fish-eating birds (25 ppm); causes eggshell thinning.'],
    ['Noise pollution effects', '>150 dB causes hearing loss; physiological stress, sleep disturbance; measure: decibel (dB).'],
    ['Chipko movement', '1974, Himalayas, India; villagers hugged trees to prevent felling; led by Gaura Devi and Sunderlal Bahuguna.'],
    ['Joint Forest Management (JFM)', '1988 India; local communities manage forests in exchange for share of produce; success story in Arabari, West Bengal.'],
    ['Radioactive waste', 'Nuclear power plants, mining generate radioactive waste; half-lives of decades-millennia; stored deep underground in shielded containers.'],
  ]);

  // ─── Helper ────────────────────────────────────────────────
  static List<FlashcardModel> _makeSimple(
      String chapter, String cls, List<List<String>> items) {
    return items.asMap().entries.map((e) => FlashcardModel(
          id: '${cls}_${chapter.substring(0, 4)}_${e.key}',
          chapter: chapter,
          front: e.value[0],
          back: e.value[1],
          studentClass: cls,
          category: 'fact',
        )).toList();
  }
}
