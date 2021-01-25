import 'package:flutter_test/flutter_test.dart';
import 'package:game_master_companion_app/NPC.dart';
import 'package:game_master_companion_app/adventure.dart';
import 'package:game_master_companion_app/strings.dart';

void main() {
  test('NPC Adventure test', () {
    Adventure adventure = Adventure();

    NPC npc = new NPC();
    npc.setID(2);
    npc.setAdventureID(3);
    npc.setStoryPointID(4);
    Map<String, bool> priorityStats = Map();
    Map<String, int> maxStats = Map();
    maxStats["test"] = 10;
    maxStats["pls"] = 21;
    priorityStats["test"] = true;
    priorityStats["pls"] = false;
    npc.generate(NPCGENRAND, maxStats, priorityStats);
    adventure.addNPC(npc);

    expect(npc.getID(), 2);
    expect(npc.getStoryPointID(), 4);
    expect(npc.adventureID, 3);
    expect(npc.stats.isNotEmpty, true);
    expect(npc.stats["test"], lessThan(11));
    expect(npc.stats["pls"], lessThan(22));

    npc.stats.clear();
    npc.generate(NPCGENSKILLPOINTS, maxStats, priorityStats,
        skillPointsNumber: 31);
    expect(npc.stats["test"], 10);
    expect(npc.stats["pls"], 21);

    npc.stats.clear();
  });
}
