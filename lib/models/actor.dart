class Actor {
  
  
  int? id;
  String? knownForDepartment;
  String? name;
  String? originalName;
  

  Actor({
    
    
    this.id,
    this.knownForDepartment,
    this.name,
    
  });

  factory Actor.fromJson(Map<String, dynamic> json) {
    return Actor(
      
      
      id: json['id'] as int?,
      knownForDepartment: json['known_for_department'] as String?,
      name: json['name'] as String?,
      
    );
  }
}