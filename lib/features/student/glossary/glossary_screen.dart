import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/glass_card.dart';

class GlossaryScreen extends StatefulWidget {
  const GlossaryScreen({super.key});

  @override
  State<GlossaryScreen> createState() => _GlossaryScreenState();
}

class _GlossaryScreenState extends State<GlossaryScreen> {
  String _search = '';
  String _filter = 'all'; // 'all' | '11' | '12'

  @override
  Widget build(BuildContext context) {
    final terms = _filtered;

    return Column(
      children: [
        Container(
          color: AppColors.neuSurface,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: LayoutBuilder(builder: (context, constraints) {
            final compact = constraints.maxWidth < 500;
            final chips = [
              for (final f in [('All', 'all'), ('Class 11', '11'), ('Class 12', '12')])
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: _Chip(f.$1, _filter == f.$2,
                      () => setState(() => _filter = f.$2)),
                ),
            ];
            final searchField = TextField(
              decoration: const InputDecoration(
                hintText: 'Search terms, definitions, full forms…',
                prefixIcon: Icon(Icons.search, size: 18),
                isDense: true,
              ),
              onChanged: (v) => setState(() => _search = v.toLowerCase()),
            );
            if (compact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  searchField,
                  const SizedBox(height: 10),
                  Row(children: chips),
                ],
              );
            }
            return Row(
              children: [
                Expanded(child: searchField),
                const SizedBox(width: 10),
                ...chips,
              ],
            );
          }),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(children: [
            Text('${terms.length} terms',
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary)),
          ]),
        ),
        Expanded(
          child: terms.isEmpty
              ? const Center(
                  child: Text('No terms found',
                      style: TextStyle(color: AppColors.textHint)))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: terms.length,
                  itemBuilder: (_, i) {
                    final t = terms[i];
                    return _TermTile(term: t, search: _search)
                        .animate(delay: (i * 15).ms)
                        .fadeIn(duration: 150.ms);
                  },
                ),
        ),
      ],
    );
  }

  List<_GlossaryTerm> get _filtered {
    return _glossaryData.where((t) {
      final matchClass = _filter == 'all' || t.cls == _filter;
      final matchSearch = _search.isEmpty ||
          t.term.toLowerCase().contains(_search) ||
          t.definition.toLowerCase().contains(_search) ||
          (t.fullForm?.toLowerCase().contains(_search) ?? false);
      return matchClass && matchSearch;
    }).toList();
  }
}

// Builds RichText with yellow-highlighted matching substrings
TextSpan _highlight(String text, String query, TextStyle base) {
  if (query.isEmpty) return TextSpan(text: text, style: base);
  final lower = text.toLowerCase();
  final q = query.toLowerCase();
  final spans = <TextSpan>[];
  int start = 0;
  while (true) {
    final idx = lower.indexOf(q, start);
    if (idx == -1) {
      spans.add(TextSpan(text: text.substring(start), style: base));
      break;
    }
    if (idx > start) {
      spans.add(TextSpan(text: text.substring(start, idx), style: base));
    }
    spans.add(TextSpan(
      text: text.substring(idx, idx + q.length),
      style: base.copyWith(
        backgroundColor: const Color(0xFFFFE082),
        color: const Color(0xFF5D4037),
        fontWeight: FontWeight.w800,
      ),
    ));
    start = idx + q.length;
  }
  return TextSpan(children: spans);
}

class _TermTile extends StatefulWidget {
  final _GlossaryTerm term;
  final String search;
  const _TermTile({required this.term, this.search = ''});

  @override
  State<_TermTile> createState() => _TermTileState();
}

class _TermTileState extends State<_TermTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.term;
    final clsColor = t.cls == '11' ? AppColors.batch11 : AppColors.batch12;

    return SolidCard(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      onTap: () => setState(() => _expanded = !_expanded),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: RichText(
                            text: _highlight(
                              t.term,
                              widget.search,
                              const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  color: AppColors.textPrimary),
                            ),
                          ),
                        ),
                        if (t.fullForm != null) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                                color: AppColors.infoSurface,
                                borderRadius: BorderRadius.circular(5)),
                            child: Text(t.fullForm!,
                                style: const TextStyle(
                                    fontSize: 10,
                                    color: AppColors.info,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ],
                    ),
                    if (!_expanded)
                      RichText(
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        text: _highlight(
                          t.definition,
                          widget.search,
                          const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              height: 1.5),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: clsColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text('Class ${t.cls}',
                        style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: clsColor)),
                  ),
                  const SizedBox(height: 4),
                  Icon(
                      _expanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      size: 18,
                      color: AppColors.textHint),
                ],
              ),
            ],
          ),
          if (_expanded) ...[
            const SizedBox(height: 8),
            RichText(
              text: _highlight(
                t.definition,
                widget.search,
                const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    height: 1.65),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(6)),
              child: Text(
                t.chapter,
                style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

Widget _Chip(String label, bool selected, VoidCallback onTap) =>
    GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.neuBackground,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: selected ? AppColors.primary : AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : AppColors.textSecondary),
        ),
      ),
    );

// ─── Data ────────────────────────────────────────────────────
class _GlossaryTerm {
  final String term;
  final String definition;
  final String? fullForm;
  final String chapter;
  final String cls;
  const _GlossaryTerm(this.term, this.definition, this.chapter, this.cls,
      {this.fullForm});
}

const _glossaryData = <_GlossaryTerm>[
  // Class 11
  _GlossaryTerm('Biodiversity', 'Variety and variability among living organisms and the ecological complexes in which they occur.', 'The Living World', '11'),
  _GlossaryTerm('Taxonomy', 'Science of identification, nomenclature and classification of organisms.', 'The Living World', '11'),
  _GlossaryTerm('Binomial nomenclature', 'System of naming organisms with two-part names (genus + species) proposed by Linnaeus.', 'The Living World', '11'),
  _GlossaryTerm('Metabolism', 'Sum total of all chemical reactions in a living organism.', 'The Living World', '11'),
  _GlossaryTerm('Homeostasis', 'Tendency of an organism to maintain a constant internal environment despite external changes.', 'The Living World', '11'),
  _GlossaryTerm('ICZN', 'International Code of Zoological Nomenclature; governs the naming of animals.', 'The Living World', '11', fullForm: 'ICZN'),
  _GlossaryTerm('Herbarium', 'A collection of dried, pressed plant specimens mounted on sheets for scientific study.', 'The Living World', '11'),
  _GlossaryTerm('Archaebacteria', 'Ancient bacteria that thrive in extreme environments (hot springs, salt lakes, marshes); have unique membrane lipids.', 'Biological Classification', '11'),
  _GlossaryTerm('Cyanobacteria', 'Photosynthetic prokaryotes (blue-green algae) that can fix atmospheric nitrogen.', 'Biological Classification', '11'),
  _GlossaryTerm('Mycorrhiza', 'Mutualistic association between fungi and plant roots; increases mineral and water absorption.', 'Biological Classification', '11'),
  _GlossaryTerm('Lichen', 'Symbiotic association of a fungus (mycobiont) and an alga (phycobiont); indicator of air pollution.', 'Biological Classification', '11'),
  _GlossaryTerm('Prion', 'Infectious misfolded protein; causes diseases like BSE and Creutzfeldt-Jakob disease.', 'Biological Classification', '11'),
  _GlossaryTerm('Viroid', 'Smallest infectious agent; infective RNA without protein coat; causes plant diseases.', 'Biological Classification', '11'),
  _GlossaryTerm('Metagenesis', 'Alternation of asexual (polyp) and sexual (medusa) phases in coelenterates.', 'Animal Kingdom', '11'),
  _GlossaryTerm('Coelom', 'Body cavity lined by mesodermal epithelium; provides space for organs.', 'Animal Kingdom', '11'),
  _GlossaryTerm('Notochord', 'Rod-like mesodermal structure present at least in embryonic stage of chordates.', 'Animal Kingdom', '11'),
  _GlossaryTerm('Radula', 'Rasping/scraping organ in molluscs used for feeding.', 'Animal Kingdom', '11'),
  _GlossaryTerm('Water vascular system', 'Unique hydraulic system in echinoderms; operates tube feet for locomotion and feeding.', 'Animal Kingdom', '11'),
  _GlossaryTerm('Phyllotaxy', 'Pattern of leaf arrangement on a stem (alternate, opposite, or whorled).', 'Morphology of Flowering Plants', '11'),
  _GlossaryTerm('Placentation', 'Arrangement of ovules within the ovary.', 'Morphology of Flowering Plants', '11'),
  _GlossaryTerm('Aestivation', 'Mode of arrangement of sepals or petals in a flower bud with respect to each other.', 'Morphology of Flowering Plants', '11'),
  _GlossaryTerm('Inflorescence', 'Arrangement of flowers on the floral axis.', 'Morphology of Flowering Plants', '11'),
  _GlossaryTerm('Totipotency', 'Ability of a single cell to divide and produce all differentiated cells in an organism.', 'Cell: The Unit of Life', '11'),
  _GlossaryTerm('Fluid mosaic model', 'Model of cell membrane structure with a phospholipid bilayer and embedded proteins (Singer & Nicolson, 1972).', 'Cell: The Unit of Life', '11'),
  _GlossaryTerm('Ribosome', 'Non-membrane bound organelle; site of protein synthesis; 70S in prokaryotes, 80S in eukaryotes.', 'Cell: The Unit of Life', '11'),
  _GlossaryTerm('Cristae', 'Foldings of the inner mitochondrial membrane; increase surface area for ATP synthesis.', 'Cell: The Unit of Life', '11'),
  _GlossaryTerm('Thylakoid', 'Flattened membrane sacs in chloroplasts; stacked into grana; site of light reactions.', 'Cell: The Unit of Life', '11'),
  _GlossaryTerm('Nucleosome', 'Basic unit of DNA packaging; 200 bp DNA wound around histone octamer.', 'Cell: The Unit of Life', '11'),
  _GlossaryTerm('Km', 'Michaelis constant; substrate concentration at which enzyme activity is half-maximal; indicates enzyme-substrate affinity.', 'Biomolecules', '11'),
  _GlossaryTerm('Allosteric regulation', 'Regulation of enzyme activity by binding of a molecule at a site other than the active site.', 'Biomolecules', '11'),
  _GlossaryTerm('Chargaff\'s rule', 'In double-stranded DNA, A = T and G = C (purines = pyrimidines).', 'Biomolecules', '11'),
  _GlossaryTerm('Prosthetic group', 'Non-protein component permanently attached to an enzyme, essential for its activity.', 'Biomolecules', '11'),
  _GlossaryTerm('Crossing over', 'Exchange of chromosomal segments between non-sister chromatids of homologous chromosomes during Prophase I.', 'Cell Cycle and Cell Division', '11'),
  _GlossaryTerm('Synaptonemal complex', 'Protein scaffold holding homologous chromosomes together during meiotic synapsis.', 'Cell Cycle and Cell Division', '11'),
  _GlossaryTerm('Kinetochore', 'Protein complex on centromere where spindle fibres attach during cell division.', 'Cell Cycle and Cell Division', '11'),
  _GlossaryTerm('Casparian strip', 'Suberin-impregnated band in root endodermis that blocks apoplastic water movement.', 'Anatomy of Flowering Plants', '11'),
  _GlossaryTerm('Lenticels', 'Pores in the bark of woody plants that allow gas exchange after secondary growth.', 'Anatomy of Flowering Plants', '11'),
  _GlossaryTerm('Heartwood', 'Dark, non-functional inner wood; provides mechanical support; contains resins and oils.', 'Anatomy of Flowering Plants', '11'),
  _GlossaryTerm('Transpiration', 'Loss of water vapour from aerial plant parts, mainly through stomata.', 'Transport in Plants', '11'),
  _GlossaryTerm('Imbibition', 'Absorption of water by solid substances; results in swelling; generates imbibition pressure.', 'Transport in Plants', '11'),
  _GlossaryTerm('Guttation', 'Exudation of liquid water from hydathodes at leaf margins; occurs at night/high humidity.', 'Transport in Plants', '11'),
  _GlossaryTerm('Nif gene', 'Nitrogenase gene; codes for the enzyme that reduces N₂ to NH₃ during biological nitrogen fixation.', 'Mineral Nutrition', '11'),
  _GlossaryTerm('Leghaemoglobin', 'Oxygen-scavenging protein in root nodules that maintains anaerobic conditions needed by nitrogenase.', 'Mineral Nutrition', '11'),
  _GlossaryTerm('Photorespiration', 'Oxygenase activity of RuBisCO; produces phosphoglycolate; wasteful in C3 plants; absent in C4 plants.', 'Photosynthesis in Higher Plants', '11'),
  _GlossaryTerm('Z-scheme', 'Path of electrons in non-cyclic photophosphorylation from water through PS-II to PS-I to NADP+.', 'Photosynthesis in Higher Plants', '11'),
  _GlossaryTerm('RuBisCO', 'Ribulose bisphosphate carboxylase-oxygenase; the enzyme that fixes CO₂ in the Calvin cycle; most abundant enzyme on Earth.', 'Photosynthesis in Higher Plants', '11', fullForm: 'RuBisCO'),
  _GlossaryTerm('EMP pathway', 'Embden-Meyerhof-Parnas pathway; another name for glycolysis.', 'Respiration in Plants', '11', fullForm: 'EMP'),
  _GlossaryTerm('RQ', 'Respiratory quotient; ratio of CO₂ produced to O₂ consumed during respiration.', 'Respiration in Plants', '11', fullForm: 'RQ'),
  _GlossaryTerm('Amphibolic pathway', 'Metabolic pathway that serves both catabolic (breakdown) and anabolic (synthesis) roles, e.g., Krebs cycle.', 'Respiration in Plants', '11'),
  _GlossaryTerm('Photoperiodism', 'Response of a plant to the relative duration of light and dark periods.', 'Plant Growth and Development', '11'),
  _GlossaryTerm('Vernalisation', 'Promotion of flowering in plants by exposure to cold temperatures.', 'Plant Growth and Development', '11'),
  _GlossaryTerm('Bolting', 'Rapid elongation of the shoot axis before flowering; often triggered by gibberellins.', 'Plant Growth and Development', '11'),
  _GlossaryTerm('GFR', 'Glomerular filtration rate; volume of filtrate formed per minute (~125 mL/min in humans).', 'Excretory Products and their Elimination', '11', fullForm: 'GFR'),
  _GlossaryTerm('ADH', 'Antidiuretic hormone (vasopressin); secreted by posterior pituitary; increases water reabsorption in collecting duct.', 'Excretory Products and their Elimination', '11', fullForm: 'ADH'),
  _GlossaryTerm('JGA', 'Juxtaglomerular apparatus; senses low blood pressure; secretes renin to raise BP.', 'Excretory Products and their Elimination', '11', fullForm: 'JGA'),
  _GlossaryTerm('Sinoatrial node', 'Pacemaker of the heart; located in right atrium; generates 70–75 impulses/min.', 'Body Fluids and Circulation', '11', fullForm: 'SAN'),
  _GlossaryTerm('Stroke volume', 'Volume of blood pumped by the left ventricle per beat (~70 mL).', 'Body Fluids and Circulation', '11'),
  _GlossaryTerm('Bohr effect', 'Decrease in haemoglobin oxygen affinity caused by high CO₂/low pH; promotes O₂ release in tissues.', 'Breathing and Exchange of Gases', '11'),
  _GlossaryTerm('Tidal volume', 'Volume of air inspired or expired in a single normal breath (~500 mL).', 'Breathing and Exchange of Gases', '11', fullForm: 'TV'),
  _GlossaryTerm('Vital capacity', 'Maximum volume of air a person can breathe out after maximum inspiration (~4500 mL = IRV + TV + ERV).', 'Breathing and Exchange of Gases', '11', fullForm: 'VC'),
  _GlossaryTerm('Sliding filament theory', 'Muscle contraction occurs when actin filaments slide over myosin, shortening the sarcomere.', 'Locomotion and Movement', '11'),
  _GlossaryTerm('Rigor mortis', 'Stiffening of muscles after death due to inability to break actin-myosin cross-bridges without ATP.', 'Locomotion and Movement', '11'),
  _GlossaryTerm('EEG', 'Electroencephalogram; records electrical activity of the brain using surface electrodes.', 'Neural Control and Coordination', '11', fullForm: 'EEG'),
  _GlossaryTerm('Synapse', 'Junction between two neurons; neurotransmitters bridge the synaptic cleft.', 'Neural Control and Coordination', '11'),
  _GlossaryTerm('Action potential', 'Brief, all-or-none reversal of membrane polarity (from –70 mV to +30 mV) that travels along a nerve fibre.', 'Neural Control and Coordination', '11'),
  _GlossaryTerm('Prostaglandins', 'Locally acting lipid mediators derived from arachidonic acid; involved in inflammation, fever, pain.', 'Chemical Coordination and Integration', '11'),
  _GlossaryTerm('Melatonin', 'Hormone from pineal gland that regulates circadian rhythms and seasonal breeding.', 'Chemical Coordination and Integration', '11'),

  // Class 12
  _GlossaryTerm('Sporopollenin', 'Most resistant organic material; forms exine of pollen grains; can withstand extreme temperatures and acids.', 'Sexual Reproduction in Flowering Plants', '12'),
  _GlossaryTerm('Apomixis', 'Seed formation without fertilisation; e.g., dandelion; maintains genetic uniformity.', 'Sexual Reproduction in Flowering Plants', '12'),
  _GlossaryTerm('Double fertilisation', 'Fusion of one sperm with egg (→zygote) and another sperm with two polar nuclei (→triploid PEN); unique to angiosperms.', 'Sexual Reproduction in Flowering Plants', '12'),
  _GlossaryTerm('Polyembryony', 'Presence of more than one embryo in a seed; e.g., Citrus (nucellar embryony).', 'Sexual Reproduction in Flowering Plants', '12'),
  _GlossaryTerm('Spermiogenesis', 'Transformation of spermatids into spermatozoa (sperm cells).', 'Human Reproduction', '12'),
  _GlossaryTerm('Corpus luteum', 'Endocrine structure formed from Graafian follicle after ovulation; secretes progesterone.', 'Human Reproduction', '12'),
  _GlossaryTerm('hCG', 'Human chorionic gonadotropin; secreted by trophoblast; maintains corpus luteum; detected in pregnancy tests.', 'Human Reproduction', '12', fullForm: 'hCG'),
  _GlossaryTerm('Colostrum', 'First milk secreted after parturition; rich in IgA antibodies; yellowish.', 'Human Reproduction', '12'),
  _GlossaryTerm('Acrosome reaction', 'Release of enzymes from acrosome at sperm head upon contact with zona pellucida; allows sperm penetration.', 'Human Reproduction', '12'),
  _GlossaryTerm('IVF', 'In vitro fertilisation; fertilisation outside the body; zygote transferred to uterus.', 'Reproductive Health', '12', fullForm: 'IVF'),
  _GlossaryTerm('MTP', 'Medical termination of pregnancy; legal in India up to 20 weeks.', 'Reproductive Health', '12', fullForm: 'MTP'),
  _GlossaryTerm('MOET', 'Multiple ovulation embryo transfer; technique to produce multiple embryos from one superior female.', 'Strategies for Enhancement in Food Production', '12', fullForm: 'MOET'),
  _GlossaryTerm('Heterosis', 'Superiority of F1 hybrid over both parents; also called hybrid vigour.', 'Strategies for Enhancement in Food Production', '12'),
  _GlossaryTerm('Biofortification', 'Breeding crops with higher levels of vitamins, minerals, proteins or healthier fats.', 'Strategies for Enhancement in Food Production', '12'),
  _GlossaryTerm('SCP', 'Single cell protein; protein-rich biomass from microorganisms used as food supplement.', 'Strategies for Enhancement in Food Production', '12', fullForm: 'SCP'),
  _GlossaryTerm('BOD', 'Biological oxygen demand; amount of oxygen needed by bacteria to decompose organic matter; indicator of water pollution.', 'Microbes in Human Welfare', '12', fullForm: 'BOD'),
  _GlossaryTerm('Bioremediation', 'Use of microorganisms to clean up environmental pollutants.', 'Microbes in Human Welfare', '12'),
  _GlossaryTerm('Restriction enzyme', 'Endonuclease that cuts double-stranded DNA at specific palindromic sequences; "molecular scissors".', 'Biotechnology: Principles and Processes', '12'),
  _GlossaryTerm('PCR', 'Polymerase chain reaction; exponential amplification of specific DNA sequences in vitro.', 'Biotechnology: Principles and Processes', '12', fullForm: 'PCR'),
  _GlossaryTerm('Gel electrophoresis', 'Technique to separate DNA/RNA/proteins by size in an electric field through agarose or polyacrylamide gel.', 'Biotechnology: Principles and Processes', '12'),
  _GlossaryTerm('pBR322', 'First artificially constructed recombinant plasmid vector; has ampR, tetR genes and multiple restriction sites.', 'Biotechnology: Principles and Processes', '12'),
  _GlossaryTerm('Bt toxin', 'Crystalline protein toxin from Bacillus thuringiensis; insecticidal; used in Bt crops.', 'Biotechnology and its Applications', '12'),
  _GlossaryTerm('RNAi', 'RNA interference; gene silencing by complementary dsRNA that targets specific mRNA for degradation.', 'Biotechnology and its Applications', '12', fullForm: 'RNAi'),
  _GlossaryTerm('ELISA', 'Enzyme-linked immunosorbent assay; antigen-antibody based diagnostic test.', 'Biotechnology and its Applications', '12', fullForm: 'ELISA'),
  _GlossaryTerm('Gene therapy', 'Correction of a genetic disorder by introducing a functional copy of the gene into cells.', 'Biotechnology and its Applications', '12'),
  _GlossaryTerm('Biopiracy', 'Unauthorised use of biological resources or traditional knowledge of communities.', 'Biotechnology and its Applications', '12'),
  _GlossaryTerm('Hardy-Weinberg equilibrium', 'Principle that allele frequencies in a population remain constant in the absence of evolutionary forces.', 'Evolution', '12'),
  _GlossaryTerm('Genetic drift', 'Random change in allele frequency in a small population; includes bottleneck and founder effects.', 'Evolution', '12'),
  _GlossaryTerm('Adaptive radiation', 'Diversification of a common ancestral species into multiple forms to fill different ecological niches.', 'Evolution', '12'),
  _GlossaryTerm('Opsonisation', 'Coating of pathogens with antibodies or complement proteins to enhance phagocytosis.', 'Human Health and Disease', '12'),
  _GlossaryTerm('Anaphylaxis', 'Severe, life-threatening allergic reaction; rapid onset; treated with epinephrine (adrenaline).', 'Human Health and Disease', '12'),
  _GlossaryTerm('Eutrophication', 'Excessive nutrient enrichment of water bodies leading to algal blooms and O₂ depletion.', 'Environmental Issues', '12'),
  _GlossaryTerm('Biomagnification', 'Progressive increase in concentration of a toxin at each successive trophic level.', 'Environmental Issues', '12'),
  _GlossaryTerm('Ozone hole', 'Seasonal thinning of stratospheric ozone over Antarctica due to CFC-mediated destruction.', 'Environmental Issues', '12'),
  _GlossaryTerm('Acid rain', 'Precipitation with pH < 5.6 due to SO₂ and NOₓ dissolving in atmospheric water.', 'Environmental Issues', '12'),
  _GlossaryTerm('Ecological succession', 'Sequential replacement of one community by another until a stable climax community is reached.', 'Ecosystem', '12'),
  _GlossaryTerm('GPP', 'Gross primary productivity; total photosynthesis per unit area per time.', 'Ecosystem', '12', fullForm: 'GPP'),
  _GlossaryTerm('NPP', 'Net primary productivity; GPP minus plant respiration; energy available for consumers.', 'Ecosystem', '12', fullForm: 'NPP'),
  _GlossaryTerm('Detritivores', 'Organisms that feed on dead organic matter (detritus); fragment it for further decomposition.', 'Ecosystem', '12'),
  _GlossaryTerm('Lindemann\'s 10% law', 'Only ~10% of energy is transferred from one trophic level to the next; rest lost as heat.', 'Ecosystem', '12'),
  _GlossaryTerm('Sacred groves', 'Forest patches protected by local/tribal communities for religious reasons; biodiversity refugia.', 'Biodiversity and Conservation', '12'),
  _GlossaryTerm('Biodiversity hotspot', 'Region with ≥1500 endemic plant species AND ≥70% habitat loss; requires urgent conservation.', 'Biodiversity and Conservation', '12'),
  _GlossaryTerm('Ex-situ conservation', 'Conservation of species outside their natural habitat; e.g., zoos, seed banks, botanical gardens.', 'Biodiversity and Conservation', '12'),
  _GlossaryTerm('In-situ conservation', 'Conservation of species within their natural habitat; e.g., national parks, wildlife sanctuaries, biosphere reserves.', 'Biodiversity and Conservation', '12'),
  _GlossaryTerm('Competitive exclusion principle', 'Two species competing for identical resources cannot coexist; one is excluded (Gause\'s principle).', 'Organisms and Populations', '12'),
  _GlossaryTerm('Carrying capacity (K)', 'Maximum population size that can be sustainably supported by the environment.', 'Organisms and Populations', '12'),
  _GlossaryTerm('Mutualism', 'Interaction between two species where both benefit (+/+); e.g., mycorrhiza, lichens, Rhizobium-legume.', 'Organisms and Populations', '12'),
  _GlossaryTerm('Commensalism', 'Interaction where one species benefits and the other is neither helped nor harmed (+/0); e.g., orchid on tree.', 'Organisms and Populations', '12'),
  _GlossaryTerm('Amensalism', 'Interaction where one species is harmed and the other is unaffected (−/0); e.g., Penicillium secretes penicillin harming bacteria.', 'Organisms and Populations', '12'),
];
