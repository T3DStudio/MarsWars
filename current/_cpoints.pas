
procedure CPoint_ChangeOwner(i,newOwnerPlayer:byte);
var p:byte;
begin
   with g_KeyPoints[i] do
   if(kp_OwnerPlayer<>newOwnerPlayer)then
   begin
      if(kp_OwnerTeam<=LastPlayer)then
       for p:=0 to LastPlayer do
        with g_players[p] do
         if(team=kp_OwnerTeam)then
         begin
            cenergy-=kp_energy;
            menergy-=kp_energy;
         end;
      kp_OwnerPlayer:=newOwnerPlayer;
      kp_OwnerTeam  :=newOwnerPlayer;
      if(newOwnerPlayer<=LastPlayer)then
      begin
         kp_OwnerTeam:=g_players[newOwnerPlayer].team;
         if(kp_OwnerTeam>0)then
          for p:=0 to LastPlayer do
           with g_players[p] do
            if(team=kp_OwnerTeam)then
            begin
               cenergy+=kp_energy;
               menergy+=kp_energy;
            end;
      end;
   end;
end;

procedure GameModeKeyPoints;
var i,p,
iOwnerTeam,
iOwnerPlayer,
iArmy,iTeams,
wteam  ,
wteam_n,
kp_captured_n :integer;
begin
   {for i:=0 to LastKeyPoint do
    with g_KeyPoints[i] do
    if(kp_CaptureR>0)then
    begin
       p:=0;
       if(map_scenario=ms_royale)and(g_RoyalBattle_r<kp_ToCenterD)then p:=1;
       if(kp_lifeTime>0)and(kp_OwnerTeam>0)then
       begin
          kp_lifeTime-=1;
          if(kp_lifeTime=0)then p:=1;
       end;

       if(p>0)then
       begin
          CPoint_ChangeOwner(i,255);
          kp_CaptureR:=-kp_CaptureR;
          {$IFDEF _FULLGAME}
          effect_CPExplode(kp_x,kp_y);
          {$ENDIF}
          continue;
       end;

       kp_PlayerUnit_p:=kp_PlayerUnits;
       kp_TeamLimit_p :=kp_TeamUnits;
       iOwnerPlayer   :=kp_OwnerPlayer;
       iOwnerTeam     :=kp_OwnerTeam;
       iArmy :=0;
       iTeams:=0;
       for p:=0 to LastPlayer do
       begin
          if(kp_TeamUnits[p]>0)then
          begin
             iTeams+=1;
             iOwnerTeam:=p;
          end;
          if(kp_PlayerUnits[p]>iArmy)or(iArmy=0)then
          begin
             iArmy:=kp_PlayerUnits[p];
             iOwnerPlayer:=p;
          end;
          kp_PlayerUnits[p]:=0;
          kp_TeamUnits  [p]:=0;
       end;

       if((iTeams=0)and(kp_energy>0))
       or((i=1)and(map_scenario=ms_KotH)and(g_step<g_step_koth_pause))then
       begin
          iTeams:=0;
          iOwnerPlayer:=255;
          iOwnerTeam  :=255;
       end;

       if(iTeams=0)
       then kp_Timer:=0
       else
         if(iTeams=1)then
          if(kp_OwnerTeam=iOwnerTeam)
          then kp_Timer:=0
          else
          begin
             kp_TimerPlayer:=iOwnerPlayer;
             if(kp_TimerTeam<>iOwnerTeam)then
             begin
                kp_TimerTeam:=iOwnerTeam;
                kp_Timer:=0;
             end;
             if(kp_Timer<kp_CaptureTime)
             then kp_Timer+=1
             else
             begin
                kp_Timer:=0;
                CPoint_ChangeOwner(i,iOwnerPlayer);
             end;
          end;
    end;

   // VICTORY CONDITIONS
   wteam        :=0;
   wteam_n      :=0;
   kp_captured_n:=0;

   for i:=1 to LastKeyPoint do
    with g_KeyPoints[i] do
     if(kp_CaptureR>0)and(kp_energy<=0)then
     begin
        kp_captured_n+=1;
        if(kp_OwnerTeam>0)then
        begin
           if(wteam=0)
           or(wteam<>kp_OwnerTeam)
           then wteam_n:=0;
           wteam  :=kp_OwnerTeam;
           wteam_n+=1;
        end;
     end;

   if(kp_captured_n>0)and(wteam_n=kp_captured_n)then GameSetStatusWinnerTeam(wteam);  }
end;

