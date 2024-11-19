import 'package:flutter/material.dart';

class DiseaseInformationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Disease Information'),
        backgroundColor: Colors.orange[600],
      ),
      body: ListView(
        children: [
          _buildDiseaseCategory(
            context,
            "Fungal Diseases",
            [
              "Powdery Mildew",
              "Downy Mildew",
              "Septoria Leaf Spot",
              "Leaf Blight (Alternaria blight)",
              "Phytophthora Root Rot",
              "Fusarium Wilt",
              "Verticillium Wilt",
              "Sclerotinia Stem and Crown Rot",
              "Black Stem Rust (Puccinia graminis)",
              "Leaf Rust (common in grains)",
              "Botrytis Rot (Gray Mold)",
              "Anthracnose",
            ],
          ),
          _buildDiseaseCategory(
            context,
            "Bacterial Diseases",
            [
              "Bacterial Leaf Spot",
              "Halo Blight",
              "Bacterial Wilt",
              "Crown Gall",
              "Bacterial Soft Rot (common in high-humidity conditions)",
              "Fire Blight",
              "Black Rot",
            ],
          ),
          _buildDiseaseCategory(
            context,
            "Viral Diseases",
            [
              "Tobacco Mosaic Virus (TMV)",
              "Cucumber Mosaic Virus (CMV)",
              "Tomato Mosaic Virus (ToMV)",
              "Tomato Spotted Wilt Virus (TSWV)",
              "Aster Yellow Virus",
              "Bean Common Mosaic Virus (BCMV)",
              "Lettuce Mosaic Virus (LMV)",
              "Potato Virus Y (PVY)",
              "Zucchini Yellow Mosaic Virus (ZYMV)",
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDiseaseCategory(BuildContext context, String category, List<String> diseases) {
    return ExpansionTile(
      title: Text(
        category,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.orange[600],
        ),
      ),
      children: diseases.map((disease) {
        return ListTile(
          title: Text(disease),
          onTap: () {
            _showDiseaseDetails(context, disease);
          },
        );
      }).toList(),
    );
  }

  void _showDiseaseDetails(BuildContext context, String disease) {
    String description = _getDiseaseDescription(disease);
    String causes = _getDiseaseCauses(disease);
    String remedies = _getDiseaseRemedies(disease);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(disease),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Description:", style: TextStyle(fontWeight: FontWeight.bold)),
              Text(description),
              SizedBox(height: 10),
              Text("Causes:", style: TextStyle(fontWeight: FontWeight.bold)),
              Text(causes),
              SizedBox(height: 10),
              Text("Remedies:", style: TextStyle(fontWeight: FontWeight.bold)),
              Text(remedies),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  String _getDiseaseDescription(String disease) {
    switch (disease) {
      case "Powdery Mildew":
        return "Powdery mildew is a fungal disease that affects plants by producing a powdery white coating on the surface of leaves.";
      case "Downy Mildew":
        return "Downy mildew is a water mold that causes yellowing and wilting of leaves.";
      case "Septoria Leaf Spot":
        return "Septoria leaf spot is a fungal disease characterized by dark, circular spots on leaves.";
      case "Leaf Blight (Alternaria blight)":
        return "Leaf blight caused by Alternaria fungi leads to brown, necrotic spots on leaves.";
    // Add descriptions for other diseases here...
      default:
        return "Information not available.";
    }
  }

  String _getDiseaseCauses(String disease) {
    switch (disease) {
      case "Powdery Mildew":
        return "Caused by fungal pathogens like *Erysiphe* species that thrive in dry, warm conditions.";
      case "Downy Mildew":
        return "Caused by water molds (Oomycetes), especially in humid, wet conditions, often spreading through water droplets.";
      case "Septoria Leaf Spot":
        return "Caused by *Septoria* fungi that infect plants through water splash, often under humid conditions.";
      case "Leaf Blight (Alternaria blight)":
        return "Caused by *Alternaria* fungi, often due to poor air circulation and high humidity.";
    // Add causes for other diseases here...
      default:
        return "Causes not available.";
    }
  }

  String _getDiseaseRemedies(String disease) {
    switch (disease) {
      case "Powdery Mildew":
        return "Use fungicides like sulfur or neem oil. Ensure proper air circulation and reduce humidity.";
      case "Downy Mildew":
        return "Improve drainage and airflow. Apply fungicides like copper or phosphorous acid.";
      case "Septoria Leaf Spot":
        return "Prune infected leaves and use fungicides. Avoid overhead watering to reduce spread.";
      case "Leaf Blight (Alternaria blight)":
        return "Remove infected leaves and apply fungicides like chlorothalonil or mancozeb.";
    // Add remedies for other diseases here...
      default:
        return "Remedies not available.";
    }
  }
}
