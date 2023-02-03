
procedure CPoint_ChangeOwner(i,newOwnerPlayer:byte);
var p:byte;
begin
   if(newOwnerPlayer<=MaxPlayers)then
   with g_cpoints[i] do
   if(cpOwnerPlayer<>newOwnerPlayer)then
   begin
      if(cpOwnerTeam>0)then
       for p:=0 to MaxPlayers do
        with _players[p] do
         if(team=cpOwnerTeam)then
         begin
            cenergy-=cpenergy;
            menergy-=cpenergy;
         end;
      cpOwnerPlayer:=newOwnerPlayer;
      cpOwnerTeam  :=_players[newOwnerPlayer].team;
      if(cpOwnerTeam>0)then
       for p:=0 to MaxPlayers do
        with _players[p] do
         if(team=cpOwnerTeam)then
         begin
            cenergy+=cpenergy;
            menergy+=cpenergy;
         end;
   end;
end;

procedure GameModeCPoints;
var i,p,iOwnerTeam,iOwnerPlayer,iArmy,iTeams,
wteam,
wteam_n   ,
cp_captured_n :integer;
begin
   for i:=1 to MaxCPoints do
    with g_cpoints[i] do
    if(cpCapturer>0)then
    begin
       if(cplifetime>0)and(cpOwnerTeam>0)then
       begin
          cplifetime-=1;
          if(cplifetime=0)then
          begin
             CPoint_ChangeOwner(i,0);
             cpCapturer:=-cpCapturer;
             {$IFDEF _FULLGAME}
             _CPExplode(cpx,cpy);
             {$ENDIF}
          end;
       end;

       cpunitsp_pstate:=cpUnitsPlayer;
       cpunitst_pstate:=cpUnitsTeam;
       iOwnerPlayer   :=cpOwnerPlayer;
       iOwnerTeam     :=cpOwnerTeam;
       iArmy :=0;
       iTeams:=0;
       for p:=0 to MaxPlayers do
       begin
          if(cpUnitsTeam[p]>0)then
          begin
             iTeams+=1;
             iOwnerTeam:=p;
          end;
          if(cpUnitsPlayer[p]>iArmy)or(iArmy=0)then
          begin
             iArmy:=cpUnitsPlayer[p];
             iOwnerPlayer:=p;
          end;
          cpUnitsPlayer[p]:=0;
          cpUnitsTeam  [p]:=0;
       end;

       if(iTeams=0)and(cpenergy>0)then
       begin
          iTeams:=1;
          iOwnerTeam  :=0;
          iOwnerPlayer:=0;
       end;

       if(iTeams=0)
       then cpTimer:=0
       else
         if(iTeams=1)then
          if(cpOwnerTeam=iOwnerTeam)
          then cpTimer:=0
          else
          begin
             cpTimerOwnerPlayer:=iOwnerPlayer;
             if(cpTimerOwnerTeam<>iOwnerTeam)then
             begin
                cpTimerOwnerTeam:=iOwnerTeam;
                cpTimer:=0;
             end;
             if(cpTimer<cpCaptureTime)
             then cpTimer+=1
             else
             begin
                cpTimer:=0;
                CPoint_ChangeOwner(i,iOwnerPlayer);
             end;
          end;
    end;

   // VICTORY CONDITIONS
   wteam        :=0;
   wteam_n      :=0;
   cp_captured_n:=0;

   for i:=1 to MaxCPoints do
    with g_cpoints[i] do
     if(cpCapturer>0)and(cpenergy<=0)then
     begin
        cp_captured_n+=1;
        if(cpOwnerTeam>0)then
        begin
           if(wteam=0)
           or(wteam<>cpOwnerTeam)
           then wteam_n:=0;
           wteam  :=cpOwnerTeam;
           wteam_n+=1;
        end;
     end;

   if(cp_captured_n>0)and(wteam_n=cp_captured_n)then GameSetStatusWinnerTeam(wteam);
end;

