
procedure KeyPoints_Clear;
var i:byte;
begin
   FillChar(g_KeyPoints,SizeOf(g_KeyPoints),0);
   for i:=0 to LastKeyPoint do
     with g_KeyPoints[i] do
     begin
        kpOwnerPlayer     :=255;
        kpOwnerTeam       :=255;
        kpTimerOwnerTeam  :=255;
        kpTimerOwnerPlayer:=255;
     end;
end;

procedure KeyPoint_ChangeOwner(i,newOwnerPlayer:byte;log:boolean=true);
begin
   with g_KeyPoints[i] do
     if(kpOwnerPlayer<>newOwnerPlayer)then
     begin
        if(kpOwnerPlayer<=LastPlayer)then
        begin
           with g_gplayers[kpOwnerPlayer] do
           begin
              energyl_cur-=kpEnergy;
              energyl_max-=kpEnergy;
           end;
           if(log)then GameLog_KeyPointLost(kpOwnerPlayer,i);
        end;

        kpOwnerPlayer:=newOwnerPlayer;
        if(kpOwnerPlayer<=LastPlayer)
        then kpOwnerTeam:=g_gplayers[newOwnerPlayer].team
        else kpOwnerTeam:=kpOwnerPlayer;

        if(kpOwnerPlayer<=LastPlayer)then
        begin
           with g_gplayers[kpOwnerPlayer] do
           begin
              energyl_cur+=kpEnergy;
              energyl_max+=kpEnergy;
           end;
           if(log)then GameLog_KeyPointCaptured(kpOwnerPlayer,i);
        end;
     end;
end;

procedure Scenario_KeyPointsCode;
var
i,p,
iOwnerPlayer,
iPlayers,
iTeams  : integer;
begin
   for i:=0 to LastKeyPoint do
     with g_KeyPoints[i] do
       if(kpCaptureR>0)then
       begin
          p:=0;
          if(map_scenario=mc_royale)and(g_royal_r<kpToCenterD)then p:=1;
          if(kplifetime>0)and(kpOwnerPlayer<=LastPlayer)then
          begin
             kplifetime-=1;
             if(kplifetime=0)then p:=1;
          end;

          if(p>0)then // life expired
          begin
             GameLog_NgenExh(kpOwnerPlayer,i);
             KeyPoint_ChangeOwner(i,255,false);
             kpCaptureR:=-kpCaptureR;
             {$IFDEF _FULLGAME}
             effect_KPointExplode(kpx,kpy);
             {$ENDIF}
             continue;
          end;

          iPlayers:=0;
          iOwnerPlayer:=kpOwnerPlayer;
          kpunitsp_pstate:=kpUnitsPlayer;
          kpunitst_pstate:=kpUnitsTeam;
          if(kpTimerOwnerPlayer<=LastPlayer)then
            if(kpUnitsPlayer[kpTimerOwnerPlayer]>0)then
            begin
               iPlayers:=1;
               iOwnerPlayer:=kpTimerOwnerPlayer;
            end;

          iTeams:=0;
          for p:=0 to LastPlayer do
          begin
             if(kpUnitsPlayer[p]>0)and(p<>kpTimerOwnerPlayer)then
             begin
                if(iPlayers=0)then iOwnerPlayer:=p;
                iPlayers+=1;
             end;
             if(kpUnitsTeam  [p]>0)then
               iTeams+=1;

             kpUnitsPlayer[p]:=0;
             kpUnitsTeam  [p]:=0;
          end;

       if((iPlayers=0)and(kpEnergy>0))
       or((i=0)and(map_scenario=mc_KotH)and(g_tick<g_step_koth_pause))then
       begin
          iPlayers:=1;
          iOwnerPlayer:=255;
       end;

       if(iPlayers=0)
       then kpTimer:=0
       else
         if(iPlayers=1)or(iTeams=1)then
           if(kpOwnerPlayer=iOwnerPlayer)
           then kpTimer:=0
           else
           begin
              if(kpTimerOwnerPlayer<>iOwnerPlayer)then
              begin
                 kpTimerOwnerPlayer:=iOwnerPlayer;
                 if(kpTimerOwnerPlayer<=LastPlayer)
                 then kpTimerOwnerTeam:=g_gplayers[kpTimerOwnerPlayer].team
                 else kpTimerOwnerTeam:=255;
                 if(i=0)and(map_scenario=mc_KotH)then GameLog_KotHControl;
                 kpTimer:=0;
              end;
              if(kpTimer<kpCaptureTime)
              then kpTimer+=1
              else
              begin
                 kpTimer:=0;
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
     if(kpCaptureR>0)and(kpEnergy<=0)then
     begin
        kp_captured_n+=1;
        if(kpOwnerTeam<=LastPlayer)then
        begin
           if(wteam=255)
           or(wteam<>kpOwnerTeam)
           then wteam_n:=0;
           wteam  :=kpOwnerTeam;
           wteam_n+=1;
        end;
     end;

   if(kp_captured_n>0)and(wteam_n=kp_captured_n)and(wteam<=LastPlayer)then Game_SetStatusWinnerTeam(wteam);
end;

