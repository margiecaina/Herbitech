import 'package:flutter/material.dart';

class PlantInformationPage extends StatelessWidget {
  // List of plant names
  final List<String> plantNames = [
    'Akapulko', 'Ampalaya', 'Atis', 'Banaba', 'Bawang', 'Bayabas',
    'Gumamela', 'Lagundi', 'Luya', 'Niyog-Niyogan', 'Oregano', 'Pansit-Pansitan',
    'Sabila', 'Sambong', 'Tsaang Gubat', 'Ulasimang Bato', 'Yerba Buena', 'Virgin Coconut Oil'
  ];


  // Information for each plant
  final Map<String, String> plantInfo = {
  'Akapulko': '''
**Plant Type**: Shrub\n\n
**Health Benefits**:
- Known to be a diuretic, sudorific, and purgative.
- Treats fungal infections of the skin and ringworms.\n\n
**Growth Stages**:
1. Germination: Seeds sprout in 7-14 days.
2. Seedling Stage: Develops in moist, well-drained soil.
3. Vegetative Stage: Grows into a bush with large leaves.
4. Flowering Stage: Produces bright yellow flowers.
5. Mature Plant: Fully established with many branches.\n
  ''',

  'Ampalaya': '''
**Plant Type**: Vegetable\n\n
**Health Benefits**:
- Used to treat diabetes (diabetes mellitus).
- Commercially produced in tablet form and tea bags.\n\n
**Growth Stages**:
1. Germination: Seeds sprout in 7-10 days in warm soil.
2. Seedling Stage: Transplant into the garden when seedlings are a few inches tall.
3. Vegetative Stage: Grows with broad, green leaves and bitter fruits.
4. Flowering Stage: Small yellow flowers.
5. Mature Plant: Grows to full size, bearing green to orange fruits.\n
  ''',

  'Atis': '''
**Plant Type**: Tree\n\n
**Health Benefits**:
- Used to treat diarrhea, dysentery, and fainting.
- The leaves, fruit, and seeds are medicinal.\n\n
**Growth Stages**:
1. Germination: Seeds sprout in 7-14 days.
2. Seedling Stage: Transplant into the garden when seedlings are ready.
3. Vegetative Stage: Small tree with large, green leaves.
4. Flowering Stage: Produces sweet-smelling flowers.
5. Mature Tree: Full-sized tree with green, scaly fruits.\n
  ''',

  'Banaba': '''
**Plant Type**: Tree\n\n
**Health Benefits**:
- Used in the treatment of diabetes and other ailments.
- Has purgative and diuretic effects.\n\n
**Growth Stages**:
1. Germination: Seeds sprout in 14-21 days.
2. Seedling Stage: Transplant seedlings into a sunny, well-drained area.
3. Vegetative Stage: Tree grows with oval-shaped leaves.
4. Flowering Stage: Small, purple flowers bloom.
5. Mature Tree: Reaches full size, with large, broad leaves and purple flowers.\n
  ''',

  'Bawang': '''
**Plant Type**: Herb\n\n
**Health Benefits**:
- Used to reduce cholesterol and lower blood pressure.\n\n
**Growth Stages**:
1. Germination: Seeds sprout in 7-14 days.
2. Seedling Stage: Plant in well-drained soil.
3. Vegetative Stage: Develops thick green leaves.
4. Flowering Stage: Produces small white flowers.
5. Mature Herb: Harvest when bulbs have grown full size.\n
  ''',

  'Bayabas': '''
**Plant Type**: Tree\n\n
**Health Benefits**:
- Used as a disinfectant for treating wounds and as a mouthwash for gum infections.
- The bark is used for treating diarrhea in children.\n\n
**Growth Stages**:
1. Germination: Seeds sprout in 7-14 days.
2. Seedling Stage: Develop seedlings in rich, well-drained soil.
3. Vegetative Stage: Tree grows with dark green, leathery leaves.
4. Flowering Stage: Produces small, white flowers.
5. Mature Tree: Grows into a small tree with edible guava fruits.\n
  ''',

  'Gumamela': '''
**Plant Type**: Shrub\n\n
**Health Benefits**:
- Used as an expectorant for coughs, cold, sore throat, fever, and bronchitis.\n\n
**Growth Stages**:
1. Germination: Seeds sprout in 10-14 days.
2. Seedling Stage: Plant in well-drained, fertile soil.
3. Vegetative Stage: Shrub grows with large, bright flowers.
4. Flowering Stage: Produces large, colorful flowers.
5. Mature Plant: Fully grown shrub with many flowers.\n
  ''',

  'Lagundi': '''
**Plant Type**: Shrub\n\n
**Health Benefits**:
- Used to treat coughs, asthma, dyspepsia, rheumatism, and boils.
- Known for its expectorant and febrifuge properties.\n\n
**Growth Stages**:
1. Germination: Seeds sprout in 10-14 days.
2. Seedling Stage: Plant in moist, well-drained soil.
3. Vegetative Stage: Bushy shrub with five-lobed leaves.
4. Flowering Stage: Small, purple flowers bloom.
5. Mature Shrub: Fully grown shrub with medicinal leaves.\n
  ''',

  'Luya': '''
**Plant Type**: Herb (Ginger)\n\n
**Health Benefits**:
- Known for antifungal, anti-inflammatory, antibiotic, and antiviral properties.
- Used for digestive issues, colds, and inflammation.\n\n
**Growth Stages**:
1. Germination: Rhizomes sprout in 14-21 days.
2. Seedling Stage: Plant in moist, warm soil.
3. Vegetative Stage: Grows into a tall, leafy herb.
4. Flowering Stage: Produces small, yellow-green flowers.
5. Mature Herb: Harvest rhizomes after 8-10 months of growth.\n
  ''',

  'Niyog-Niyogan': '''
**Plant Type**: Vine\n\n
**Health Benefits**:
- Used for eliminating intestinal worms and treating diarrhea and skin diseases.\n\n
**Growth Stages**:
1. Germination: Seeds sprout in 10-14 days.
2. Seedling Stage: Plant in fertile, well-drained soil.
3. Vegetative Stage: Vine grows thick with long stems.
4. Flowering Stage: Small, pinkish flowers bloom.
5. Mature Vine: Fully grown vine that climbs structures.\n
  ''',

  'Oregano': '''
**Plant Type**: Herb\n\n
**Health Benefits**:
- Known for its antimicrobial and anti-inflammatory properties.
- Used to relieve coughs, asthma, and upset stomach.\n\n
**Growth Stages**:
1. Germination: Seeds sprout in 7-14 days.
2. Seedling Stage: Plant in moist, well-drained soil.
3. Vegetative Stage: Grows into a bushy herb with aromatic leaves.
4. Flowering Stage: Produces small, purple flowers.
5. Mature Herb: Grows full-sized with a strong aroma.\n
  ''',

  'Pansit-Pansitan': '''
**Plant Type**: Herb\n\n
**Health Benefits**:
- Used to treat arthritis, gout, skin disorders, and abdominal pains.
- Helps with kidney problems.\n\n
**Growth Stages**:
1. Germination: Seeds sprout in 7-10 days.
2. Seedling Stage: Plant in well-drained, sunny soil.
3. Vegetative Stage: Grows with soft, succulent leaves.
4. Flowering Stage: Produces small, white flowers.
5. Mature Herb: Becomes bushy with many leaves.\n
  ''',

  'Sabila': '''
**Plant Type**: Herb (Aloe Vera)\n\n
**Health Benefits**:
- Used to treat burns, cuts, eczema, and other skin disorders.
- Known for its antifungal, antibiotic, and antioxidant properties.\n\n
**Growth Stages**:
1. Germination: Seeds sprout in 14-21 days.
2. Seedling Stage: The plant grows with thick, fleshy leaves.
3. Vegetative Stage: Aloe vera grows into a rosette of leaves.
4. Flowering Stage: May produce tall flower spikes with orange-yellow flowers.
5. Mature Herb: Fully grown with many leaves for harvesting.\n
  ''',

  'Sambong': '''
**Plant Type**: Shrub\n\n
**Health Benefits**:
- Used for kidney disorders, rheumatism, hypertension, and colds.
- Known for its diuretic properties.\n\n
**Growth Stages**:
1. Germination: Seeds sprout in 14-21 days.
2. Seedling Stage: Grow in fertile, moist soil.
3. Vegetative Stage: Shrub develops broad, thick leaves.
4. Flowering Stage: Small, purple flowers bloom.
5. Mature Shrub: Fully grown with medicinal leaves.\n
  ''',

  'Tsaang Gubat': '''
**Plant Type**: Shrub\n\n
**Health Benefits**:
- Effective for treating diarrhea, dysentery, and stomach ailments.
- Used as a mouthwash to prevent tooth decay.\n\n
**Growth Stages**:
1. Germination: Seeds sprout in 14-21 days.
2. Seedling Stage: Grow in nutrient-rich soil.
3. Vegetative Stage: Shrub develops small leaves.
4. Flowering Stage: Small white flowers bloom.
5. Mature Shrub: Fully grown with aromatic leaves.\n
  ''',

  'Ulasimang Bato': '''
**Plant Type**: Herb\n\n
**Health Benefits**:
- Used to treat gout, arthritis, and prevents uric acid buildup.\n\n
**Growth Stages**:
1. Germination: Seeds sprout in 7-10 days.
2. Seedling Stage: Grow in moist, well-drained soil.
3. Vegetative Stage: Herb develops thick stems.
4. Flowering Stage: Small, greenish flowers appear.
5. Mature Herb: Fully grown and ready for harvest.\n
  ''',

  'Yerba Buena': '''
**Plant Type**: Vine\n\n
**Health Benefits**:
- Known for its analgesic properties, helps relieve body aches and pains.\n\n
**Growth Stages**:
1. Germination: Seeds sprout in 7-14 days.
2. Seedling Stage: Grow in well-drained, moist soil.
3. Vegetative Stage: Vine develops fragrant leaves.
4. Flowering Stage: Produces small, purple flowers.
5. Mature Vine: Fully grown, leaves harvested for medicinal use.\n
  ''',

  'Virgin Coconut Oil': '''
**Plant Type**: Product (from Coconut)\n\n
**Health Benefits**:
- Used to treat diabetes, high blood pressure, and skin conditions.
- Nourishes and heals the skin and scalp.\n\n
**Growth Stages**:
1. Germination: Not applicable, as it's a product of the coconut tree.
2. Seedling Stage: Not applicable.
3. Vegetative Stage: Not applicable.
4. Flowering Stage: Not applicable.
5. Mature Tree: Coconuts are harvested for oil extraction.\n
  '''
  };


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Plant Information'),
        backgroundColor: Colors.green[600],
      ),
      body: ListView.builder(
        itemCount: plantNames.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 5,
            child: ListTile(
              contentPadding: EdgeInsets.all(16),
              title: Text(
                plantNames[index],
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              subtitle: Text('Tap for details', style: TextStyle(color: Colors.green[700])),
              trailing: Icon(Icons.arrow_forward, color: Colors.green[600]),
              onTap: () {
                // Show plant information when tapped
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text(plantNames[index]),
                      content: Text(plantInfo[plantNames[index]] ?? 'No information available for this plant.'),
                      actions: <Widget>[
                        TextButton(
                          child: Text('Close'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
