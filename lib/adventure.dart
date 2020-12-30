class Adventure{

  Map<int,Set<int>> storyPoints;
  void addStoryPoint(int previous,int next)
  {

    if(next == null && previous != null)
      {
        
        if(storyPoints[previous].first==-1)
          storyPoints[previous].remove(-1);
        
      storyPoints[storyPoints.length].add(-1);
      storyPoints[previous].add(storyPoints.length);
      }else if(previous==null)
        {
          storyPoints[storyPoints.length].add(-1);
        }

  }
  void editStoryPoint()
  {

  }

}