class Adventure {
  Map<int, StoryPoint> storyPoints;

  Adventure() {
    storyPoints = new Map();
  }

  void addStoryPoint(int index) {
    if (!storyPoints.containsKey(index))
      storyPoints[index] = new StoryPoint(index);
  }

  void removeStoryPoint(int key) {
    storyPoints.remove(key);
  }

  void editStoryPointPlayers(int key, String players) {
    storyPoints[key].players = players;
  }

  void editStoryPointNote(int key, String note) {
    storyPoints[key].note = note;
  }

  void editStoryPointOrder(int key, int storyOrder) {
    storyPoints.forEach((id, value) {
      if (id != key) {
        if (value.storyOrder >= storyOrder) value.storyOrder++;
      }
    });
    storyPoints[key].storyOrder = storyOrder;
  }

  void addConnection(int key, int connection) {
    storyPoints[key].setConnection(connection);
  }

  Set getConnections(int key) {
    return storyPoints[key].getConnections();
  }
}

class StoryPoint {
  int storyOrder;
  String note;
  String players;
  NPC npcs;
  Event events;
  Set connections;

  void setConnection(int connection) {
    connections.add(connection);
  }

  Set getConnections() {
    return connections;
  }

  StoryPoint(int order) {
    storyOrder = order;
    connections = Set();
    events = Event();
    npcs = NPC();
  }

  void setStoryOrder(int storyOrder) {
    this.storyOrder = storyOrder;
  }
}

class NPC {
  bool isImportant;
}

class Event {
  bool isRandom;
}
