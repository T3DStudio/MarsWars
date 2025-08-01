
procedure KeyPoints_Clear;
var i:byte;
begin
   FillChar(g_KeyPoints,SizeOf(g_KeyPoints),0);
   for i:=0 to LastKeyPoint do
     with g_KeyPoints[i] do
     begin
        cpOwnerPlayer     :=255;
        cpOwnerTeam       :=255;
        cpTimerOwnerTeam  :=255;
        cpTimerOwnerPlayer:=255;
     end;
end;

procedure KeyPoint_ChangeOwner(i,newOwnerPlayer:byte;log:boolean=true);
begin
   with g_KeyPoints[i] do
     if(cpOwnerPlayer<>newOwnerPlayer)then
     begin
        if(cpOwnerPlayer<=LastPlayer)then
        begin
           with g_players[cpOwnerPlayer] do
           begin
              cenergy-=cpenergy;
              menergy-=cpenergy;
           end;
           if(log)then GameLogKeyPointLost(cpOwnerPlayer,i);
        end;

        cpOwnerPlayer:=newOwnerPlayer;
        if(cpOwnerPlayer<=LastPlayer)
        then cpOwnerTeam:=g_players[newOwnerPlayer].team
        else cpOwnerTeam:=cpOwnerPlayer;

        if(cpOwnerPlayer<=LastPlayer)then
        begin
           with g_players[cpOwnerPlayer] do
           begin
              cenergy+=cpenergy;
              menergy+=cpenergy;
           end;
           if(log)then GameLogKeyPointCaptured(cpOwnerPlayer,i);
        end;
     end;
end;

procedure Scenario_KeyPointsCode;
var
i,p,
iOwnerPlayer,
iPlayers: integer;
begin
   for i:=0 to LastKeyPoint do
     with g_KeyPoints[i] do
       if(cpCaptureR>0)then
       begin
          p:=0;
          if(map_scenario=mc_royale)and(g_royal_r<cp_ToCenterD)then p:=1;
          if(cplifetime>0)and(cpOwnerPlayer<=LastPlayer)then
          begin
             cplifetime-=1;
             if(cplifetime=0)then p:=1;
          end;

          if(p>0)then // life expired
          begin
             GameLogNGenExh(cpOwnerPlayer,i);
             KeyPoint_ChangeOwner(i,255,false);
             cpCaptureR:=-cpCaptureR;
             {$IFDEF _FULLGAME}
             effect_KPointExplode(cpx,cpy);
             {$ENDIF}
             continue;
          end;

          cpunitsp_pstate:=cpUnitsPlayer;
          cpunitst_pstate:=cpUnitsTeam;
          iOwnerPlayer   :=cpOwnerPlayer;
          iPlayers:=0;
          for p:=0 to LastPlayer do
          begin
             if(cpUnitsPlayer[p]>0)then
             begin
                iPlayers+=1;
                iOwnerPlayer:=p;
             end;
             cpUnitsPlayer[p]:=0;
             cpUnitsTeam  [p]:=0;
          end;

       if((iPlayers=0)and(cpenergy>0))
       or((i=0)and(map_scenario=mc_KotH)and(g_tick<g_step_koth_pause))then
       begin
          iPlayers:=1;
          iOwnerPlayer:=255;
       end;

       if(iPlayers=0)
       then cpTimer:=0
       else
         if(iPlayers=1)then
           if(cpOwnerPlayer=iOwnerPlayer)
           then cpTimer:=0
           else
           begin
              if(cpTimerOwnerPlayer<>iOwnerPlayer)then
              begin
                 cpTimerOwnerPlayer:=iOwnerPlayer;
                 if(cpTimerOwnerPlayer<=LastPlayer)
                 then cpTimerOwnerTeam:=g_players[cpTimerOwnerPlayer].team
                 else cpTimerOwnerTeam:=255;
                 if(i=0)and(map_scenario=mc_KotH)then GameLogKotHControl;
                 cpTimer:=0;
              end;
              if(cpTimer<cpCaptureTime)
              then cpTimer+=1
              else
              begin
                 cpTimer:=0;
                 KeyPoint_ChangeOwner(i,iOwnerPlayer);
              end;
           end;
    end;
end;

procedure Scenario_KeyPointsEndConditions;
var i,
wteam  ,
wteam_n,
kp_captured_n :integer;
begin
   // VICTORY CONDITIONS
   wteam        :=255;
   wteam_n      :=0;
   kp_captured_n:=0;

   for i:=0 to LastKeyPoint do
    with g_KeyPoints[i] do
     if(cpCaptureR>0)and(cpenergy<=0)then
     begin
        kp_captured_n+=1;
        if(cpOwnerTeam<=LastPlayer)then
        begin
           if(wteam=255)
           or(wteam<>cpOwnerTeam)
           then wteam_n:=0;
           wteam  :=cpOwnerTeam;
           wteam_n+=1;
        end;
     end;

   if(kp_captured_n>0)and(wteam_n=kp_captured_n)and(wteam<=LastPlayer)then GameSetStatusWinnerTeam(wteam);
end;

