
{$IFDEF _FULLGAME}
procedure KeyPoints_UpdateVisData;
var kpi:byte;
begin
   for kpi:=0 to LastKeyPoint do
     with map_KeyPointsL[kpi] do
     with map_KeyPointsVis[kpi] do
     begin
        kpmmx:=round(map_MiniMap_cx*kp_x);
        kpmmy:=round(map_MiniMap_cx*kp_y);
        kpmmr:=round(map_MiniMap_cx*kp_RCapture);
     end;
end;

procedure KeyPoints_Explode(kpi:byte);
begin
   with map_KeyPointsL[kpi] do
     with kp_TeamData[KeyPoint_GetPlayerTeam(UIPlayer)] do
       if(kptd_Active)and(kptd_VisTimer>0)then
         effect_KPointExplode(kp_x,kp_y);
end;

{$ENDIF}

procedure KeyPoints_Clear;
var i:byte;
begin
   map_KeyPointsN:=0;
   FillChar(map_KeyPointsL,SizeOf(map_KeyPointsL),0);
   for i:=0 to LastKeyPoint do
     with map_KeyPointsL[i] do
     with kp_TeamData[MaxPlayers] do
     begin
        kptd_VisTimer        :=fr_fps1;
        kptd_OwnerPlayer     :=255;
        kptd_OwnerTeam       :=255;
        kptd_TimerOwnerTeam  :=255;
        kptd_TimerOwnerPlayer:=255;
     end;
end;

procedure KeyPoint_ChangeOwner(kpi,newOwnerPlayer:byte;log:boolean=true);
begin
   with map_KeyPointsL[kpi] do
   with kp_TeamData[MaxPlayers] do
     if(kptd_OwnerPlayer<>newOwnerPlayer)then
     begin
        if(kptd_OwnerPlayer<=LastPlayer)then
        begin
           with g_gplayers[kptd_OwnerPlayer] do
           begin
              res_energyl_cur-=kp_Energy;
              res_energyl_max-=kp_Energy;
           end;
           if(log)then GameLog_KeyPointLost(kptd_OwnerPlayer,kpi);
        end;

        kptd_OwnerPlayer:=newOwnerPlayer;
        if(kptd_OwnerPlayer<=LastPlayer)
        then kptd_OwnerTeam:=g_gplayers[newOwnerPlayer].team
        else kptd_OwnerTeam:=kptd_OwnerPlayer;

        if(kptd_OwnerPlayer<=LastPlayer)then
        begin
           with g_gplayers[kptd_OwnerPlayer] do
           begin
              res_energyl_cur+=kp_Energy;
              res_energyl_max+=kp_Energy;
           end;
           if(log)then GameLog_KeyPointCaptured(kptd_OwnerPlayer,kpi);
        end;
     end;
end;

procedure Scenario_KeyPointsTeam;
var
i,p  :byte;
pkptv:PTKeyPointTeamData;
begin
   for i:=0 to LastKeyPoint do
     with map_KeyPointsL[i] do
     begin
        pkptv:=@kp_TeamData[MaxPlayers];
        for p:=0 to LastPlayer do
          with kp_TeamData[p] do
            if(kptd_VisTimer>0)then
            begin
               kptd_VisTimer-=1;
               kptd_Active          :=pkptv^.kptd_Active;
               kptd_TimerOwnerTeam  :=pkptv^.kptd_TimerOwnerTeam;
               kptd_TimerOwnerPlayer:=pkptv^.kptd_TimerOwnerPlayer;
               kptd_OwnerPlayer     :=pkptv^.kptd_OwnerPlayer;
               kptd_OwnerTeam       :=pkptv^.kptd_OwnerTeam;
               kptd_Timer           :=pkptv^.kptd_Timer;
               kptd_lifeTime        :=pkptv^.kptd_lifeTime;
            end;
     end;
end;

procedure Scenario_KeyPointsCodeServer;
var
i,p,
tCapturingPlayer,
tPlayers,
tTeams  : integer;

begin
   Scenario_KeyPointsTeam;

   for i:=0 to LastKeyPoint do
     with map_KeyPointsL[i] do
     with kp_TeamData[MaxPlayers] do
       if(kptd_Active)then
       begin
          if(map_scenario=mc_royale)and(g_royal_r<kp_ToCenterD)then kptd_Active:=false;
          if(kptd_lifeTime>0)and(kptd_OwnerPlayer<=LastPlayer)then
          begin
             kptd_lifeTime-=1;
             if(kptd_lifeTime=0)then kptd_Active:=false
          end;

          if(not kptd_Active)then
          begin
             GameLog_NgenExh(kptd_OwnerPlayer,i);
             KeyPoint_ChangeOwner(i,255,false);
             {$IFDEF _FULLGAME}
             KeyPoints_Explode(i);
             {$ENDIF}
             continue;
          end;

          tPlayers:=0;
          tCapturingPlayer:=kptd_OwnerPlayer;
          kp_LimitPlayerP :=kp_LimitPlayerC;
          kp_LimitTeamP   :=kp_LimitTeamC;
          if(kptd_TimerOwnerPlayer<=LastPlayer)then
            if(kp_LimitPlayerC[kptd_TimerOwnerPlayer]>0)then
            begin
               tPlayers:=1;
               tCapturingPlayer:=kptd_TimerOwnerPlayer;
            end;

          tTeams:=0;
          for p:=0 to LastPlayer do
          begin
             if(kp_LimitPlayerC[p]>0)and(p<>kptd_TimerOwnerPlayer)then
             begin
                if(tPlayers=0)then tCapturingPlayer:=p;
                tPlayers+=1;
             end;
             if(kp_LimitTeamC  [p]>0)then
               tTeams+=1;

             kp_LimitPlayerC[p]:=0;
             kp_LimitTeamC  [p]:=0;
          end;

          if((tPlayers=0)and(kp_Energy>0))
          or((i=0)and(map_scenario=mc_KotH)and(g_tick<keyPoint_KotH_pause))then
          begin
             tPlayers:=1;
             tCapturingPlayer:=255;
          end;

          if(tPlayers=0)then
          begin
             kptd_Timer:=0;
             kptd_TimerOwnerPlayer:=255;
             kptd_TimerOwnerTeam  :=255;
          end
          else
            if(tPlayers=1)or(tTeams=1)then
              if(kptd_OwnerPlayer=tCapturingPlayer)then
              begin
                 kptd_Timer:=0;
                 kptd_TimerOwnerPlayer:=255;
                 kptd_TimerOwnerTeam  :=255;
              end
              else
              begin
                 if(kptd_TimerOwnerPlayer<>tCapturingPlayer)then
                 begin
                    kptd_TimerOwnerPlayer:=tCapturingPlayer;
                    if(kptd_TimerOwnerPlayer<=LastPlayer)
                    then kptd_TimerOwnerTeam:=g_gplayers[kptd_TimerOwnerPlayer].team
                    else kptd_TimerOwnerTeam:=255;
                    if(i=0)and(map_scenario=mc_KotH)then GameLog_KotHControl;
                    kptd_Timer:=0;
                 end;
                 if(kptd_Timer<kp_CaptureTime)
                 then kptd_Timer+=1
                 else
                 begin
                    kptd_Timer:=0;
                    KeyPoint_ChangeOwner(i,tCapturingPlayer);
                 end;
              end;
       end;
end;

procedure Scenario_KeyPointsEndConditions;
var i,
wteam  ,
wteam_n,
kp_captured_n:integer;
begin
   // VICTORY CONDITIONS
   wteam        :=255;
   wteam_n      :=0;
   kp_captured_n:=0;

   for i:=0 to LastKeyPoint do
     with map_KeyPointsL[i] do
     with kp_TeamData[MaxPlayers] do
       if(kptd_Active)and(kp_Energy<=0)then
       begin
          kp_captured_n+=1;
          if(kptd_OwnerTeam<=LastPlayer)then
          begin
             if(wteam=255)
             or(wteam<>kptd_OwnerTeam)
             then wteam_n:=0;
             wteam  :=kptd_OwnerTeam;
             wteam_n+=1;
          end;
       end;

   if(kp_captured_n>0)and(wteam_n=kp_captured_n)and(wteam<=LastPlayer)then Game_SetStatusWinnerTeam(wteam);
end;

