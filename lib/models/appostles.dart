class Appostles {
  final String title;
  final Frontmatter frontmatter;
  final List<Section> sections;

// Appostles({
//     required this.title,
//     required this.frontmatter,
//     required this.sections,
//   });
  Appostles({required this.title,required this.frontmatter, required this.sections});

  factory Appostles.fromJson(Map<String, dynamic> json){
    return Appostles(
      title: json['title'] ?? '',
      frontmatter: Frontmatter.fromJson(json['frontmatter'] ?? {}),
      sections: (json['sections'] as List? ?? [])
      .map((s) => Section.fromJson(s))
      .toList(),
    );
  }
}
  // appostles({
  //   required this.title,
  //   required this.frontmatter,
  //   required this.sections,
  // });

class Frontmatter {
  final List<String> tags;
  final String title;
  final String created;

  Frontmatter({required this.tags, required this.title, required this.created});

  factory Frontmatter.fromJson(Map<String, dynamic> json) {
    return Frontmatter(
      tags: List<String>.from(json['tags'] ?? []),
      title: json['title'] ?? '',
      created: json['created'] ?? '',
    );
  }
}

class Section {
  final int level;
  final String heading;
  final List<ContentNode> content;
  final List<Section> subSections; // Recursive nesting

  Section({
    required this.level,
    required this.heading,
    required this.content,
    required this.subSections,
  });

  factory Section.fromJson(Map<String, dynamic> json) {
    return Section(
      level: json['level'] ?? 1,
      heading: json['heading'] ?? '',
      content: (json['content'] as List? ?? [])
          .map((c) => ContentNode.fromJson(c))
          .toList(),
      subSections: (json['sections'] as List? ?? [])
          .map((s) => Section.fromJson(s)) // Recursive call
          .toList(),
    );
  }
}

class ContentNode {
  final String type; // "paragraph" or "list"
  final String? text; // Optional context text
  final List<ListItemNode> items;

  ContentNode({required this.type, this.text, required this.items});

  factory ContentNode.fromJson(Map<String, dynamic> json) {
    return ContentNode(
      type: json['type'] ?? '',
      text: json['text'],
      items: (json['items'] as List? ?? [])
          .map((i) => ListItemNode.fromJson(i))
          .toList(),
    );
  }
}

class ListItemNode {
  final String text;
  final List<ListItemNode> children; // Recursive nested sub-list nodes

  ListItemNode({required this.text, required this.children});

  factory ListItemNode.fromJson(Map<String, dynamic> json) {
    return ListItemNode(
      text: json['text'] ?? '',
      children: (json['children'] as List? ?? [])
          .map((c) => ListItemNode.fromJson(c)) // Recursive list builder
          .toList(),
    );
  }
}