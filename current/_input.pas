
////////////////////////////////////////////////////////////////////////////////
//
//    INPUT ACTIONS
//

procedure input_InitDefaultActionHotkeys;
procedure input_SetAction(aaction:byte;aktype:TInputKeyType;adepend:byte;aktvalue:cardinal);
begin
   with input_actions[aaction] do
   begin
      ik_type   :=aktype;
      ik_value  :=aktvalue;
      ik_depend :=adepend;
      ik_astate :=as_enabled;
   end;
end;
begin
   FillChar(input_actions,SizeOf(input_actions),0);
   //              action                  input type   input keys
   input_SetAction(iAct_mlb               ,ikt_mouseb  ,0           ,SDL_BUTTON_LEFT  );
   input_SetAction(iAct_mrb               ,ikt_mouseb  ,0           ,SDL_BUTTON_RIGHT );
   input_SetAction(iAct_mmb               ,ikt_mouseb  ,0           ,SDL_BUTTON_MIDDLE);

   input_SetAction(iAct_mwu               ,ikt_mousew  ,0           ,SDL_BUTTON_WHEELUP  );
   input_SetAction(iAct_mwd               ,ikt_mousew  ,0           ,SDL_BUTTON_WHEELDOWN);

   input_SetAction(iAct_left              ,ikt_keyboard,0           ,SDLK_LEFT        );
   input_SetAction(iAct_right             ,ikt_keyboard,0           ,SDLK_RIGHT       );
   input_SetAction(iAct_up                ,ikt_keyboard,0           ,SDLK_UP          );
   input_SetAction(iAct_down              ,ikt_keyboard,0           ,SDLK_DOWN        );

   input_SetAction(iAct_esc               ,ikt_keyboard,0           ,SDLK_ESCAPE      );
   input_SetAction(iAct_return            ,ikt_keyboard,0           ,SDLK_RETURN      );
   input_SetAction(iAct_backspace         ,ikt_keyboard,0           ,SDLK_BackSpace   );

   input_SetAction(iAct_control           ,ikt_keyboard,0           ,SDLK_LCtrl       );
   input_SetAction(iAct_alt               ,ikt_keyboard,0           ,SDLK_LALt        );
   input_SetAction(iAct_shift             ,ikt_keyboard,0           ,SDLK_LShift      );

   input_SetAction(iAct_Tab               ,ikt_keyboard,0           ,SDLK_Tab         );
   input_SetAction(iAct_ScreenShot        ,ikt_keyboard,0           ,sdlk_Print       );
   input_SetAction(iAct_LastEvent         ,ikt_keyboard,0           ,SDLK_Space       );

   input_SetAction(iAct_USetGroup0        ,ikt_keyboard,iAct_control,SDLK_0           );
   input_SetAction(iAct_USetGroup1        ,ikt_keyboard,iAct_control,SDLK_1           );
   input_SetAction(iAct_USetGroup2        ,ikt_keyboard,iAct_control,SDLK_2           );
   input_SetAction(iAct_USetGroup3        ,ikt_keyboard,iAct_control,SDLK_3           );
   input_SetAction(iAct_USetGroup4        ,ikt_keyboard,iAct_control,SDLK_4           );
   input_SetAction(iAct_USetGroup5        ,ikt_keyboard,iAct_control,SDLK_5           );
   input_SetAction(iAct_USetGroup6        ,ikt_keyboard,iAct_control,SDLK_6           );
   input_SetAction(iAct_USetGroup7        ,ikt_keyboard,iAct_control,SDLK_7           );
   input_SetAction(iAct_USetGroup8        ,ikt_keyboard,iAct_control,SDLK_8           );
   input_SetAction(iAct_USetGroup9        ,ikt_keyboard,iAct_control,SDLK_9           );

   input_SetAction(iAct_UAddGroup0        ,ikt_keyboard,iAct_Alt    ,SDLK_0           );
   input_SetAction(iAct_UAddGroup1        ,ikt_keyboard,iAct_Alt    ,SDLK_1           );
   input_SetAction(iAct_UAddGroup2        ,ikt_keyboard,iAct_Alt    ,SDLK_2           );
   input_SetAction(iAct_UAddGroup3        ,ikt_keyboard,iAct_Alt    ,SDLK_3           );
   input_SetAction(iAct_UAddGroup4        ,ikt_keyboard,iAct_Alt    ,SDLK_4           );
   input_SetAction(iAct_UAddGroup5        ,ikt_keyboard,iAct_Alt    ,SDLK_5           );
   input_SetAction(iAct_UAddGroup6        ,ikt_keyboard,iAct_Alt    ,SDLK_6           );
   input_SetAction(iAct_UAddGroup7        ,ikt_keyboard,iAct_Alt    ,SDLK_7           );
   input_SetAction(iAct_UAddGroup8        ,ikt_keyboard,iAct_Alt    ,SDLK_8           );
   input_SetAction(iAct_UAddGroup9        ,ikt_keyboard,iAct_Alt    ,SDLK_9           );

   input_SetAction(iAct_USelGroup0        ,ikt_keyboard,0           ,SDLK_0           );
   input_SetAction(iAct_USelGroup1        ,ikt_keyboard,0           ,SDLK_1           );
   input_SetAction(iAct_USelGroup2        ,ikt_keyboard,0           ,SDLK_2           );
   input_SetAction(iAct_USelGroup3        ,ikt_keyboard,0           ,SDLK_3           );
   input_SetAction(iAct_USelGroup4        ,ikt_keyboard,0           ,SDLK_4           );
   input_SetAction(iAct_USelGroup5        ,ikt_keyboard,0           ,SDLK_5           );
   input_SetAction(iAct_USelGroup6        ,ikt_keyboard,0           ,SDLK_6           );
   input_SetAction(iAct_USelGroup7        ,ikt_keyboard,0           ,SDLK_7           );
   input_SetAction(iAct_USelGroup8        ,ikt_keyboard,0           ,SDLK_8           );
   input_SetAction(iAct_USelGroup9        ,ikt_keyboard,0           ,SDLK_9           );

   input_SetAction(iAct_UASlGroup0        ,ikt_keyboard,iAct_shift  ,SDLK_0           );
   input_SetAction(iAct_UASlGroup1        ,ikt_keyboard,iAct_shift  ,SDLK_1           );
   input_SetAction(iAct_UASlGroup2        ,ikt_keyboard,iAct_shift  ,SDLK_2           );
   input_SetAction(iAct_UASlGroup3        ,ikt_keyboard,iAct_shift  ,SDLK_3           );
   input_SetAction(iAct_UASlGroup4        ,ikt_keyboard,iAct_shift  ,SDLK_4           );
   input_SetAction(iAct_UASlGroup5        ,ikt_keyboard,iAct_shift  ,SDLK_5           );
   input_SetAction(iAct_UASlGroup6        ,ikt_keyboard,iAct_shift  ,SDLK_6           );
   input_SetAction(iAct_UASlGroup7        ,ikt_keyboard,iAct_shift  ,SDLK_7           );
   input_SetAction(iAct_UASlGroup8        ,ikt_keyboard,iAct_shift  ,SDLK_8           );
   input_SetAction(iAct_UASlGroup9        ,ikt_keyboard,iAct_shift  ,SDLK_9           );

   input_SetAction(iAct_Control_UAbility1 ,ikt_keyboard,0           ,SDLK_Q           );
   input_SetAction(iAct_Control_UAbility2 ,ikt_keyboard,0           ,SDLK_W           );
   input_SetAction(iAct_Control_Rebuild   ,ikt_keyboard,0           ,SDLK_E           );
   input_SetAction(iAct_Control_UAMove    ,ikt_keyboard,0           ,SDLK_A           );
   input_SetAction(iAct_Control_UAStop    ,ikt_keyboard,0           ,SDLK_S           );
   input_SetAction(iAct_Control_UAPatrol  ,ikt_keyboard,0           ,SDLK_D           );
   input_SetAction(iAct_Control_UMove     ,ikt_keyboard,0           ,SDLK_Z           );
   input_SetAction(iAct_Control_UStop     ,ikt_keyboard,0           ,SDLK_X           );
   input_SetAction(iAct_Control_UPatrol   ,ikt_keyboard,0           ,SDLK_C           );
   input_SetAction(iAct_Control_UProdCncl ,ikt_keyboard,iAct_control,SDLK_C           );
   input_SetAction(iAct_Control_UDestroy  ,ikt_keyboard,0           ,SDLK_DELETE      );
   input_SetAction(iAct_Control_USelBase  ,ikt_keyboard,0           ,SDLK_F1          );
   input_SetAction(iAct_Control_USelArmy  ,ikt_keyboard,0           ,SDLK_F2          );

   input_SetAction(iAct_SProd1            ,ikt_keyboard,0           ,SDLK_R           );
   input_SetAction(iAct_SProd2            ,ikt_keyboard,0           ,SDLK_T           );
   input_SetAction(iAct_SProd3            ,ikt_keyboard,0           ,SDLK_Y           );
   input_SetAction(iAct_SProd4            ,ikt_keyboard,0           ,SDLK_F           );
   input_SetAction(iAct_SProd5            ,ikt_keyboard,0           ,SDLK_G           );
   input_SetAction(iAct_SProd6            ,ikt_keyboard,0           ,SDLK_H           );
   input_SetAction(iAct_SProd7            ,ikt_keyboard,0           ,SDLK_V           );
   input_SetAction(iAct_SProd8            ,ikt_keyboard,0           ,SDLK_B           );
   input_SetAction(iAct_SProd9            ,ikt_keyboard,0           ,SDLK_N           );
   input_SetAction(iAct_SProd10           ,ikt_keyboard,0           ,SDLK_U           );
   input_SetAction(iAct_SProd11           ,ikt_keyboard,0           ,SDLK_I           );
   input_SetAction(iAct_SProd12           ,ikt_keyboard,0           ,SDLK_O           );
   input_SetAction(iAct_SProd13           ,ikt_keyboard,0           ,SDLK_J           );
   input_SetAction(iAct_SProd14           ,ikt_keyboard,0           ,SDLK_K           );
   input_SetAction(iAct_SProd15           ,ikt_keyboard,0           ,SDLK_L           );
   input_SetAction(iAct_SProd16           ,ikt_keyboard,iAct_control,SDLK_R           );
   input_SetAction(iAct_SProd17           ,ikt_keyboard,iAct_control,SDLK_T           );
   input_SetAction(iAct_SProd18           ,ikt_keyboard,iAct_control,SDLK_Y           );
   input_SetAction(iAct_SProd19           ,ikt_keyboard,iAct_control,SDLK_F           );
   input_SetAction(iAct_SProd20           ,ikt_keyboard,iAct_control,SDLK_G           );
   input_SetAction(iAct_SProd21           ,ikt_keyboard,iAct_control,SDLK_H           );
   input_SetAction(iAct_SProd22           ,ikt_keyboard,iAct_control,SDLK_V           );
   input_SetAction(iAct_SProd23           ,ikt_keyboard,iAct_control,SDLK_B           );
   input_SetAction(iAct_SProd24           ,ikt_keyboard,iAct_control,SDLK_N           );

   input_SetAction(iAct_InGameChat        ,ikt_keyboard,0           ,sdlk_return      );
   input_SetAction(iAct_InGameChatAll     ,ikt_keyboard,iAct_Control,sdlk_return      );
   input_SetAction(iAct_InGameChatAllies  ,ikt_keyboard,iAct_Shift  ,sdlk_return      );
   input_SetAction(iAct_InGamePause       ,ikt_keyboard,0           ,SDLK_Pause       );
   input_SetAction(iAct_InGameMenu        ,ikt_keyboard,0           ,SDLK_ESCAPE      );

   input_SetAction(iAct_test_FastTime     ,ikt_keyboard,0           ,sdlk_end         );
   input_SetAction(iAct_test_InstaProd    ,ikt_keyboard,0           ,sdlk_home        );
   input_SetAction(iAct_test_ToggleAI     ,ikt_keyboard,0           ,sdlk_pageup      );
   input_SetAction(iAct_test_iddqd        ,ikt_keyboard,0           ,sdlk_pagedown    );
   input_SetAction(iAct_test_FogToggle    ,ikt_keyboard,0           ,sdlk_backspace   );
   input_SetAction(iAct_test_DrawToggle   ,ikt_keyboard,0           ,sdlk_insert      );
   input_SetAction(iAct_test_NullUpgrades ,ikt_keyboard,0           ,SDLK_KP_MINUS    );
   input_SetAction(iAct_test_BePlayer0    ,ikt_keyboard,0           ,SDLK_KP0         );
   input_SetAction(iAct_test_BePlayer1    ,ikt_keyboard,0           ,SDLK_KP1         );
   input_SetAction(iAct_test_BePlayer2    ,ikt_keyboard,0           ,SDLK_KP2         );
   input_SetAction(iAct_test_BePlayer3    ,ikt_keyboard,0           ,SDLK_KP3         );
   input_SetAction(iAct_test_BePlayer4    ,ikt_keyboard,0           ,SDLK_KP4         );
   input_SetAction(iAct_test_BePlayer5    ,ikt_keyboard,0           ,SDLK_KP5         );
   input_SetAction(iAct_test_BePlayer6    ,ikt_keyboard,0           ,SDLK_KP6         );
   input_SetAction(iAct_test_BePlayer7    ,ikt_keyboard,0           ,SDLK_KP7         );
   input_SetAction(iAct_test_debug0       ,ikt_keyboard,0           ,SDLK_KP8         );
   input_SetAction(iAct_test_debug1       ,ikt_keyboard,0           ,SDLK_KP9         );

   input_SetAction(iAct_Replay_Fast       ,ikt_keyboard,0           ,SDLK_Q           );
   input_SetAction(iAct_Replay_Pause      ,ikt_keyboard,0           ,SDLK_W           );
   input_SetAction(iAct_Replay_Back60     ,ikt_keyboard,0           ,SDLK_A           );
   input_SetAction(iAct_Replay_Back10     ,ikt_keyboard,0           ,SDLK_S           );
   input_SetAction(iAct_Replay_Back2      ,ikt_keyboard,0           ,SDLK_D           );
   input_SetAction(iAct_Replay_Forward2   ,ikt_keyboard,0           ,SDLK_Z           );
   input_SetAction(iAct_Replay_Forward10  ,ikt_keyboard,0           ,SDLK_X           );
   input_SetAction(iAct_Replay_Forward60  ,ikt_keyboard,0           ,SDLK_C           );
   input_SetAction(iAct_Replay_POV        ,ikt_keyboard,0           ,SDLK_R           );
   input_SetAction(iAct_Replay_Log        ,ikt_keyboard,0           ,SDLK_T           );
   input_SetAction(iAct_Replay_Fog        ,ikt_keyboard,0           ,SDLK_Y           );
   input_SetAction(iAct_Replay_PlayerAll  ,ikt_keyboard,0           ,SDLK_F           );
   input_SetAction(iAct_Replay_Player0    ,ikt_keyboard,0           ,SDLK_1           );
   input_SetAction(iAct_Replay_Player1    ,ikt_keyboard,0           ,SDLK_2           );
   input_SetAction(iAct_Replay_Player2    ,ikt_keyboard,0           ,SDLK_3           );
   input_SetAction(iAct_Replay_Player3    ,ikt_keyboard,0           ,SDLK_4           );
   input_SetAction(iAct_Replay_Player4    ,ikt_keyboard,0           ,SDLK_5           );
   input_SetAction(iAct_Replay_Player5    ,ikt_keyboard,0           ,SDLK_6           );
   input_SetAction(iAct_Replay_Player6    ,ikt_keyboard,0           ,SDLK_7           );
   input_SetAction(iAct_Replay_Player7    ,ikt_keyboard,0           ,SDLK_8           );


   input_SetAction(iAct_Observer_Fog      ,ikt_keyboard,0           ,SDLK_Q           );
   input_SetAction(iAct_Observer_PlayerAll,ikt_keyboard,0          ,SDLK_E           );
   input_SetAction(iAct_Observer_Player0  ,ikt_keyboard,0           ,SDLK_1           );
   input_SetAction(iAct_Observer_Player1  ,ikt_keyboard,0           ,SDLK_2           );
   input_SetAction(iAct_Observer_Player2  ,ikt_keyboard,0           ,SDLK_3           );
   input_SetAction(iAct_Observer_Player3  ,ikt_keyboard,0           ,SDLK_4           );
   input_SetAction(iAct_Observer_Player4  ,ikt_keyboard,0           ,SDLK_5           );
   input_SetAction(iAct_Observer_Player5  ,ikt_keyboard,0           ,SDLK_6           );
   input_SetAction(iAct_Observer_Player6  ,ikt_keyboard,0           ,SDLK_7           );
   input_SetAction(iAct_Observer_Player7  ,ikt_keyboard,0           ,SDLK_8           );
end;

procedure input_ActionKeyProc(kvalue:cardinal;ktype:TInputKeyType;down:boolean);
var i:byte;
begin
   case ktype of
ikt_keyboard: case kvalue of
              SDLK_RCtrl   : kvalue:=SDLK_LCtrl;
              SDLK_RAlt    : kvalue:=SDLK_LAlt;
              SDLK_RShift  : kvalue:=SDLK_LShift;
              1105         : kvalue:=SDLK_BACKQUOTE;
              SDLK_KP_ENTER: kvalue:=SDLK_RETURN;
              end;
   end;

   // check depends
   for i:=0 to 255 do
     with input_actions[i] do
       if (ik_type =ktype )
       and(ik_value=kvalue)then
         if(ik_depend>0)and(input_actions[ik_depend].ik_timer_pressed>0)then
         begin
            case down of
            false : begin
                    ik_timer_pressed:=-1;
                    if(ik_timer_twice<=0)then
                    ik_timer_twice:=kt_TwiceDelay;
                    end;
            true  : if(ik_timer_pressed=0)then
                    ik_timer_pressed:= 1;
            end;
            exit;
         end;

   for i:=0 to 255 do
     with input_actions[i] do
       if((ik_type =ktype )
       and(ik_value=kvalue))or(i=iAct_any)then
         if(ik_depend=0)then
           case down of
           false : begin
                   ik_timer_pressed:=-1;
                   if(ik_timer_twice<=0)then
                   ik_timer_twice:=kt_TwiceDelay;
                   end;
           true  : if(ik_timer_pressed=0)then
                   ik_timer_pressed:= 1;
           end;
end;

procedure inputAction_TimerProc(keyi:byte);
begin
   with input_actions[keyi] do
   begin
      if(ik_timer_pressed<0)
      then ik_timer_pressed:=0
      else
        if(0<ik_timer_pressed)and(ik_timer_pressed<ik_timer_pressed.MaxValue)then
          if(ik_type=ikt_mousew)
          then ik_timer_pressed-=1
          else ik_timer_pressed+=1;
      if(ik_timer_twice>0)then ik_timer_twice-=1;
   end;
end;

////////////////////////////////////////////////////////////////////////////////
//
//    UI INPUT
//

procedure ui_InitControlPanelBTNActions;
begin
   FillChar(ui_panel_CTabIActs,SizeOf(ui_panel_CTabIActs),0);

   ui_panel_CTabIActs[tcc_controls,0 ]:=iAct_Control_UAbility1;
   ui_panel_CTabIActs[tcc_controls,1 ]:=iAct_Control_UAbility2;
   ui_panel_CTabIActs[tcc_controls,2 ]:=iAct_Control_Rebuild;
   ui_panel_CTabIActs[tcc_controls,3 ]:=iAct_Control_UAMove;
   ui_panel_CTabIActs[tcc_controls,4 ]:=iAct_Control_UAStop;
   ui_panel_CTabIActs[tcc_controls,5 ]:=iAct_Control_UAPatrol;
   ui_panel_CTabIActs[tcc_controls,6 ]:=iAct_Control_UMove;
   ui_panel_CTabIActs[tcc_controls,7 ]:=iAct_Control_UStop;
   ui_panel_CTabIActs[tcc_controls,8 ]:=iAct_Control_UPatrol;
   ui_panel_CTabIActs[tcc_controls,9 ]:=iAct_Control_UProdCncl;
   ui_panel_CTabIActs[tcc_controls,10]:=iAct_Control_UDestroy;
   ui_panel_CTabIActs[tcc_controls,12]:=iAct_Control_USelBase;
   ui_panel_CTabIActs[tcc_controls,13]:=iAct_Control_USelArmy;

   ui_panel_CTabIActs[tcc_replay  ,0 ]:=iAct_Replay_Fast;
   ui_panel_CTabIActs[tcc_replay  ,1 ]:=iAct_Replay_Pause;
   ui_panel_CTabIActs[tcc_replay  ,3 ]:=iAct_Replay_Back60;
   ui_panel_CTabIActs[tcc_replay  ,4 ]:=iAct_Replay_Back10;
   ui_panel_CTabIActs[tcc_replay  ,5 ]:=iAct_Replay_Back2;
   ui_panel_CTabIActs[tcc_replay  ,6 ]:=iAct_Replay_Forward2;
   ui_panel_CTabIActs[tcc_replay  ,7 ]:=iAct_Replay_Forward10;
   ui_panel_CTabIActs[tcc_replay  ,8 ]:=iAct_Replay_Forward60;
   ui_panel_CTabIActs[tcc_replay  ,9 ]:=iAct_Replay_POV;
   ui_panel_CTabIActs[tcc_replay  ,10]:=iAct_Replay_Log;
   ui_panel_CTabIActs[tcc_replay  ,11]:=iAct_Replay_Fog;
   ui_panel_CTabIActs[tcc_replay  ,12]:=iAct_Replay_PlayerAll;
   ui_panel_CTabIActs[tcc_replay  ,13]:=iAct_Replay_Player0;
   ui_panel_CTabIActs[tcc_replay  ,14]:=iAct_Replay_Player1;
   ui_panel_CTabIActs[tcc_replay  ,15]:=iAct_Replay_Player2;
   ui_panel_CTabIActs[tcc_replay  ,16]:=iAct_Replay_Player3;
   ui_panel_CTabIActs[tcc_replay  ,17]:=iAct_Replay_Player4;
   ui_panel_CTabIActs[tcc_replay  ,18]:=iAct_Replay_Player5;
   ui_panel_CTabIActs[tcc_replay  ,19]:=iAct_Replay_Player6;
   ui_panel_CTabIActs[tcc_replay  ,20]:=iAct_Replay_Player7;

   ui_panel_CTabIActs[tcc_observer,0 ]:=iAct_Observer_Fog;
   ui_panel_CTabIActs[tcc_observer,3 ]:=iAct_Observer_PlayerAll;
   ui_panel_CTabIActs[tcc_observer,4 ]:=iAct_Observer_Player0;
   ui_panel_CTabIActs[tcc_observer,5 ]:=iAct_Observer_Player1;
   ui_panel_CTabIActs[tcc_observer,6 ]:=iAct_Observer_Player2;
   ui_panel_CTabIActs[tcc_observer,7 ]:=iAct_Observer_Player3;
   ui_panel_CTabIActs[tcc_observer,8 ]:=iAct_Observer_Player4;
   ui_panel_CTabIActs[tcc_observer,9 ]:=iAct_Observer_Player5;
   ui_panel_CTabIActs[tcc_observer,10]:=iAct_Observer_Player6;
   ui_panel_CTabIActs[tcc_observer,11]:=iAct_Observer_Player7;
end;

procedure ui_EnableControlActs;
var
ucl,act,uid:byte;
POVPlayer:PTPlayer;
g_control:boolean;
ctabType :TTabControlContent;
procedure iActSetDisabled(iAct:byte;isdisabled:boolean);
begin
   with input_actions[iAct] do
     if(isdisabled)
     then ik_astate:=as_disabled
     else ik_astate:=as_enabled;
end;
procedure iActSetOnEnabled(iAct:byte;ison,isenabled:boolean);
begin
   with input_actions[iAct] do
     if(not ison)
     then ik_astate:=as_off
     else
       if(isenabled)
       then ik_astate:=as_enabled
       else ik_astate:=as_disabled;
end;
function iActIfOn(iAct:byte;ison:boolean):boolean;
begin
   with input_actions[iAct] do
   begin
      iActIfOn :=ison;
      ik_astate:=as_off;
   end;
end;

begin
   g_control:=ui_GameControlsEnabled;
   ctabType :=ui_ControlTabType;

   if(UIPlayer<=LastPlayer)
   then POVPlayer:=@g_gplayers[UIPlayer]
   else POVPlayer:=nil;

   for ucl:=0 to ui_ButtonsNum do
   begin
      act:=iAct_SProd1+ucl;
      input_actions[act].ik_astate:=as_off;
      if(POVPlayer<>nil)then
        with POVPlayer^ do
        begin
           uid:=ui_panel_uids[race,ui_tab,ucl];
           case ui_tab of
           tab_buildings: if(ui_PanelBTNUnit   (POVPlayer,uid))then iActSetDisabled(act,(CheckUnitReqs   (POVPlayer,uid)>0)or not(uid in ui_bprod_possible));
           tab_units    : if(ui_PanelBTNUnit   (POVPlayer,uid))then iActSetDisabled(act,(CheckUnitReqs   (POVPlayer,uid)>0)or(uproda >=uprodm )or(ui_uprod_cur>=ui_uprod_max)or(ui_uprod_uid_max[uid]<=0));
           tab_upgrades : if(ui_PanelBTNUpgrade(POVPlayer,uid))then iActSetDisabled(act,(CheckUpgradeReqs(POVPlayer,uid)>0)or(upproda>=upprodm)or(upprodu[uid]>=ui_pprod_max[uid]));
           end;
        end;
   end;

   iActSetOnEnabled(iAct_Control_USelBase,g_control,ui_group_f1.ugroup_n>0);
   iActSetOnEnabled(iAct_Control_USelArmy,g_control,ui_group_f2.ugroup_n>0);

   iActSetOnEnabled(iAct_InGamePause,GamePauseToggle(true) and g_control,true);
   iActSetOnEnabled(iAct_InGameMenu ,true                               ,true);

   // replay controls
   iActSetOnEnabled(iAct_Replay_Fast       ,ctabType=tcc_Replay,true);
   iActSetOnEnabled(iAct_Replay_Pause      ,ctabType=tcc_Replay,replay_Pause(true));
   iActSetOnEnabled(iAct_Replay_Back2      ,ctabType=tcc_Replay,replay_SetPlayPosition(      g_tick -(fr_fps1*2 )+1,-1     ,true));
   iActSetOnEnabled(iAct_Replay_Back10     ,ctabType=tcc_Replay,replay_SetPlayPosition(      g_tick -(fr_fps1*10)+1,-1     ,true));
   iActSetOnEnabled(iAct_Replay_Back60     ,ctabType=tcc_Replay,replay_SetPlayPosition(      g_tick -(fr_fps1*60)+1,-1     ,true));
   iActSetOnEnabled(iAct_Replay_Forward2   ,ctabType=tcc_Replay,replay_SetPlayPosition(int64(g_tick)+(fr_fps1*2 )+1,fr_fps1,true));
   iActSetOnEnabled(iAct_Replay_Forward10  ,ctabType=tcc_Replay,replay_SetPlayPosition(int64(g_tick)+(fr_fps1*10)+1,fr_fps1,true));
   iActSetOnEnabled(iAct_Replay_Forward60  ,ctabType=tcc_Replay,replay_SetPlayPosition(int64(g_tick)+(fr_fps1*60)+1,fr_fps1,true));
   iActSetOnEnabled(iAct_Replay_POV        ,ctabType=tcc_Replay,true);
   iActSetOnEnabled(iAct_Replay_Log        ,ctabType=tcc_Replay,true);
   iActSetOnEnabled(iAct_Replay_Fog        ,ctabType=tcc_Replay,true);
   iActSetOnEnabled(iAct_Replay_PlayerAll  ,ctabType=tcc_Replay,true);

   for ucl:=0 to LastPlayer do
   iActSetOnEnabled(iAct_Replay_Player0+ucl,ctabType=tcc_Replay,ui_SetPlayer(ucl,true));

   // observer controls
   iActSetOnEnabled(iAct_Observer_Fog      ,ctabType=tcc_Observer,true);
   iActSetOnEnabled(iAct_Observer_PlayerAll,ctabType=tcc_Observer,true);
   for ucl:=0 to LastPlayer do
   iActSetOnEnabled(iAct_Observer_Player0+ucl,ctabType=tcc_Observer,ui_SetPlayer(ucl,true));

   // game controls
   if(iActIfOn(iAct_Control_UAbility1,(ctabType=tcc_Controls)and(ui_uibtn_sabilityu<>nil)))then
     with ui_uibtn_sabilityu^ do
       iActSetDisabled(iAct_Control_UAbility1, GameLogBits2Message(LocalPlayer,uid^.uid_ability,lmt_argt_ability,unit_sability(ui_uibtn_sabilityu,true),x,y,true) );

   if(iActIfOn(iAct_Control_UAbility2,(ctabType=tcc_Controls)and(ui_uibtn_pabilityu<>nil)))then
     with ui_uibtn_pabilityu^ do
       iActSetDisabled(iAct_Control_UAbility2, GameLogBits2Message(LocalPlayer,uid^.uid_ability,lmt_argt_ability,unit_pability(ui_uibtn_pabilityu,0,0,0,true),x,y,true) );

   if(iActIfOn(iAct_Control_Rebuild  ,(ctabType=tcc_Controls)and(ui_uibtn_rebuildu<>nil)))then
     with ui_uibtn_rebuildu^ do
       iActSetDisabled(iAct_Control_Rebuild  , GameLogBits2Message(LocalPlayer,uid^.uid_rebuild_uid,lmt_argt_unit,unit_rebuild(ui_uibtn_rebuildu,true),x,y,true) );

   iActSetOnEnabled(iAct_Control_UAMove  ,(ctabType=tcc_Controls)and((ui_uibtn_move>0)or(ui_uibtn_attack>0)),true);
   iActSetOnEnabled(iAct_Control_UAStop  ,(ctabType=tcc_Controls)and((ui_uibtn_move>0)or(ui_uibtn_attack>0)),true);
   iActSetOnEnabled(iAct_Control_UAPatrol,(ctabType=tcc_Controls)and(ui_uibtn_apatrol>0),true);  //

   iActSetOnEnabled(iAct_Control_UMove   ,(ctabType=tcc_Controls)and( ui_uibtn_move>0),true);
   iActSetOnEnabled(iAct_Control_UStop   ,(ctabType=tcc_Controls)and( ui_uibtn_move>0),true);
   iActSetOnEnabled(iAct_Control_UPatrol ,(ctabType=tcc_Controls)and( ui_uibtn_move>0),true);

   if(iActIfOn(iAct_Control_UProdCncl,(ctabType=tcc_Controls)and(POVPlayer<>nil)))then
     with POVPlayer^ do
       iActSetDisabled(iAct_Control_UProdCncl,(uproda=0)and(upproda=0));

   if(POVPlayer<>nil)then
     iActSetOnEnabled(iAct_Control_UDestroy ,(ctabType=tcc_Controls)and(POVPlayer^.s_all>0),true);
end;

procedure MapMarker(x,y:integer);
begin
   if(net_status=ns_client)
   then net_SendMapMark(x,y)
   else GameLogMapMark(LocalPlayer,x,y);
   m_brush:=co_empty;
end;

procedure ui_CommandEffect(cmd,tar,ox1,oy1:integer);
var
i,
SelectedAll,
SelectedActions,
SelectedRebuild,
SelectedBOrders: integer;
LeaderUID      : byte;
function _checkEnemy:boolean;
begin
   _checkEnemy:=false;
   if(IsUnitRange(tar,nil))then
    if(g_units[tar].player^.team<>g_gplayers[LocalPlayer].team)then _checkEnemy:=true;
end;
procedure _PlayCommand(ss:PTSoundSet);
begin
   SoundPlayUnitCommand(ss);
   ui_UnitSelectedn:=0;
end;
procedure _ClickEffect(color:cardinal);
begin
   ui_click_eff(ox1,oy1,fr_fpsq,color);
end;
function CheckBOrders(pu:PTUnit):boolean;
begin
   CheckBOrders:=true;
   with pu^ do
   with uid^ do
   begin
      if(iscomplete)then
        if(speed>0)
        or(unit_canAttack(pu,false))
        or(unit_sAbility(pu,true)=0)
        or(unit_pAbility(pu,0,0,0,true)=0)then exit;
      if(UnitHaveRPoint(uidi))then exit;
   end;
   CheckBOrders:=false;
end;

begin
   LeaderUID      :=0;
   SelectedAll    :=0;
   SelectedBOrders:=0;
   SelectedActions:=0;
   SelectedRebuild:=0;      // ????????????????????

   with g_gplayers[LocalPlayer] do
   begin
      for i:=1 to MaxUnits do
       with g_units[i] do
        with uid^ do
         if(hits>0)and(isselected)and(playeri=LocalPlayer)then
         begin
            SelectedAll+=1;
            if(CheckBOrders(g_punits[i]))then
            begin
               SelectedBOrders+=1;
               if(iscomplete)then
               begin
                  if(LeaderUID<>0)then
                   if(uid_MaxHits1<=g_uids[LeaderUID].uid_MaxHits1)then
                    if(uid_class<g_uids[LeaderUID].uid_class)then continue;

                  LeaderUID:=uidi;
               end;
            end;
            if(uid_ability    >0)or(transportC>0)then SelectedActions+=1;
            if(uid_rebuild_uid>0)then SelectedRebuild+=1;
         end;

      case cmd of
      co_supgrade,
      co_cupgrade,
      co_sunit,
      co_cunit,
      co_pcancle  : ;
      co_rcamove,
      co_rcmove,
      co_stand,
      co_move,
      co_patrol,
      co_astand,
      co_amove,
      co_apatrol  : if(SelectedBOrders<=0)then exit;
      co_pability: if(SelectedActions<=0)then exit;
      //co_sability,
      //co_pability : if(SelectedActions<=0)then begin _PlayCommand(snd_cant_order[race]);exit;end;
      co_rebuild  : if(SelectedRebuild<=0)then exit; //_PlayCommand(snd_cant_order[race]);
      else          if(SelectedAll    <=0)then exit;
      end;
   end;

   with g_uids[LeaderUID] do
   case cmd of
   co_pability,
   co_rcmove,
   co_move,
   co_astand,
   co_stand,
   co_patrol   : _PlayCommand(uid_snd_move);
   co_amove,
   co_apatrol  : _PlayCommand(uid_snd_attack);
   co_rcamove  : if(_checkEnemy)
                 then _PlayCommand(uid_snd_attack)
                 else _PlayCommand(uid_snd_move  );
   end;

   if(IsUnitRange(tar,nil))then
   begin
      ui_umark_u:=tar;
      ui_umark_t:=fr_fpsh;
      exit;
   end;

   case cmd of
   co_pability : _ClickEffect(c_aqua  );
   co_rcamove  : _ClickEffect(c_yellow);
   co_rcmove,
   co_move,
   co_patrol   : _ClickEffect(c_lime  );
   co_amove,
   co_apatrol  : _ClickEffect(c_red   );
   end;
end;

procedure PlayerSendOrder(ox0,oy0,ox1,oy1:integer;oa0,oid,playerN:byte);
var u:integer;
begin
   if(G_Status=gs_running)and(rpls_pstate<rpls_read)then
   begin
      if(net_status=ns_client)then
      begin
         net_clearbuffer;
         net_writebyte(nmid_order);
         net_writeint (ox0);
         net_writeint (oy0);
         net_writeint (ox1);
         net_writeint (oy1);
         net_writebyte(oa0);
         net_writebyte(oid);

         with g_gplayers[LocalPlayer] do
           net_writeint(s_all);
         for u:=1 to MaxUnits do
           with g_punits[u]^ do
             if(hits>0)and(isselected)and(LocalPlayer=playeri)and(not IsUnitRange(transportU,nil))then
               net_writeint(unum);

         net_send(net_cl_svip,net_cl_svport);
      end
      else
        with g_gplayers[playerN] do
        begin
           o_x0:=ox0;
           o_y0:=oy0;
           o_x1:=ox1;
           o_y1:=oy1;
           o_a0:=oa0;
           o_id:=oid;
        end;

      if(oid=uo_corder)then ui_CommandEffect(ox0,oy0,ox1,oy1);
   end;
end;

function mouse_BrushTarget(tx,ty,mbrush:integer):integer;
var
u        : integer;
btar_pu  : PTUnit;
w,
btar_w   : byte;
pUIPlayer: pTPlayer;
function GetWeight(pu:PTUnit):byte;
begin
   GetWeight:=0;
   with pu^  do
   with uid^ do
   begin
      if(ukfly)then GetWeight+=1;
      if(btar_pu<>nil)then
      begin
         if(uid_r<btar_pu^.uid^.uid_r)then GetWeight+=2;
         if(hits<btar_pu^.hits )then GetWeight+=4;
      end;
   end;
end;
begin
   mouse_BrushTarget:=0;

   if(not PointInCam(tx,ty))then exit;

   if(UIPlayer<=LastPlayer)
   then pUIPlayer:=@g_gplayers[UIPlayer]
   else pUIPlayer:=nil;

   if(pUIPlayer<>nil)then
     case mbrush of
     1..255,
     co_patrol,
     co_apatrol : exit;
     co_pability: if(ui_uibtn_pabilityu=nil)
                  then exit
                  else
                    case ui_uibtn_pabilityu^.uid^.uid_ability of
                    uab_Teleport,
                    uab_SphereInvuln,
                    uab_HEyeVision      :;
                    else exit;
                    end;
     end;

   btar_pu:=nil;
   btar_w :=0;

   for u:=1 to MaxUnits do
     with g_punits[u]^ do
       if(hits>0)and(not isUnitRange(transportU,nil))then
       begin
          with uid^ do
            if(tx<(vx-uid_r))or((vx+uid_r)<tx)
            or(ty<(vy-uid_r))or((vy+uid_r)<ty)then continue;
          if(not ui_CheckUnitUIPlayerVision(g_punits[u],true))then continue;

          case mbrush of
          co_empty,
          co_rcamove,
          co_rcmove,
          co_move,
          co_amove,
          co_mmark   :; // allowed any units
          co_pability: if(pUIPlayer<>nil)then
                         case ui_uibtn_pabilityu^.uid^.uid_ability of
                         uab_Teleport        : if(player      <>pUIPlayer      )then continue;
                         uab_SphereInvuln,
                         uab_HEyeVision      : if(player^.team<>pUIPlayer^.team)then continue;
                         else continue;
                         end;
          end;

          w:=GetWeight(g_punits[u]);

          if(btar_pu=nil)
          then
          else
            if(w<=btar_w)
            then continue
            else ;

          btar_pu:=g_punits[u];
          btar_w :=w;
          mouse_BrushTarget:=u;
       end;
end;

procedure mouse_BrushCheck(logErrors:boolean);
var ReqBits:cardinal;
begin
   m_brushx:=mouse_map_x;
   m_brushy:=mouse_map_y;

   if(UIPlayer<>LocalPlayer)
   then m_brush:=co_empty
   else
     case m_brush of
     1..255             : if not(m_brush in ui_bprod_possible)then
                          begin
                             if(logErrors)then GameLogBits2Message(LocalPlayer,byte(m_brush),lmt_argt_unit,ureq_common,-1,-1);
                             m_brush:=co_empty;
                          end
                          else
                          begin
                             ReqBits:=CheckUnitReqs(@g_gplayers[LocalPlayer],m_brush);
                             if(ReqBits>0)then
                             begin
                                if(logErrors)then GameLogBits2Message(LocalPlayer,byte(m_brush),lmt_argt_unit,ReqBits,-1,-1);
                                m_brush:=co_empty;
                             end
                             else
                               with g_gplayers[LocalPlayer] do
                               begin
                                  if(not InputAction(iact_Control))then
                                  begin
                                     BuildingFindNewPlace(mouse_map_x,mouse_map_y,m_brush,LocalPlayer,@m_brushx,@m_brushy,g_gplayers[LocalPlayer].team);
                                     m_brushx:=mm3i(ui_cam_x,m_brushx,ui_cam_x+ui_cam_w);
                                     m_brushy:=mm3i(ui_cam_y,m_brushy,ui_cam_y+ui_cam_h);
                                  end;

                                  case CheckBuildPlace(m_brushx,m_brushy,0,0,LocalPlayer,m_brush) of
                                  0 :  m_brushc:=c_lime;
                                  1 :  m_brushc:=c_red;
                                  2 :  m_brushc:=c_blue;
                                  else m_brushc:=c_gray;
                                  end;
                               end;
                          end;
     co_pability        : if(ui_uibtn_pabilityu=nil)
                          then m_brush:=co_empty
                          else
                            with ui_uibtn_pabilityu^ do
                              if(GameLogBits2Message(LocalPlayer,uid^.uid_ability,lmt_argt_ability,unit_pability(ui_uibtn_pabilityu,0,0,0,true),x,y))
                              then m_brush:=co_empty
                              else
                                with uid^ do
                                  case uid_ability of
                                  uab_HKeepShift,
                                  uab_HTowerBlink,
                                  uab_UACCCLand         : math_push_out(mouse_map_x,mouse_map_y,uid_r                        ,unum,@m_brushx,@m_brushy,false,true,g_gplayers[LocalPlayer].team);
                                  uab_RebuildInPoint: math_push_out(mouse_map_x,mouse_map_y,g_uids[uid_rebuild_uid].uid_r,unum,@m_brushx,@m_brushy,false,true,g_gplayers[LocalPlayer].team);
                                  end;
     co_move            : if(not iActEnabled(iAct_Control_UMove   ))then m_brush:=co_empty;
     co_patrol          : if(not iActEnabled(iAct_Control_UPatrol ))then m_brush:=co_empty;
     co_amove           : if(not iActEnabled(iAct_Control_UAMove  ))then m_brush:=co_empty;
     co_apatrol         : if(not iActEnabled(iAct_Control_UAPatrol))then m_brush:=co_empty;
     else  m_brush:=co_empty
     end;
end;

procedure ui_MBrush2Command(x,y,target:integer);
begin
   case m_brush of
co_move    : PlayerSendOrder(m_brush   ,target,x,y,0,uo_corder,LocalPlayer);   // move
co_amove   : PlayerSendOrder(m_brush   ,target,x,y,0,uo_corder,LocalPlayer);   // attack
co_pability: if(ui_uibtn_pabilityu<>nil)then
             with ui_uibtn_pabilityu^.uid^ do
             PlayerSendOrder(m_brush   ,target,x,y,uid_ability,
                                                     uo_corder,LocalPlayer);
co_patrol,
co_apatrol : PlayerSendOrder(m_brush   ,0     ,x,y,0,uo_corder,LocalPlayer);
co_empty   :
        if(m_RightClickAct)// rclick
        then PlayerSendOrder(co_rcmove ,target,x,y,0,uo_corder,LocalPlayer)
        else PlayerSendOrder(co_rcamove,target,x,y,0,uo_corder,LocalPlayer);
   end;

   m_brush:=co_empty;
end;

procedure ui_ExecInGameAction(action:byte;click_type:TTabBTNClickType;clickSound:pPTSoundSet);
var
u,lbrush:integer;
function SoundOn:boolean;
begin
   SoundOn:=iActOn(action);
   if(SoundOn)then clickSound^:=snd_click;
end;
function SoundEnabled:boolean;
begin
   SoundEnabled:=false;
   if(iActOn(action))then
   begin
      SoundEnabled:=iActEnabled(action);
      if(SoundEnabled)
      then clickSound^:=snd_click
      else clickSound^:=snd_cant_order[r_hell];
   end;
end;
function SoundEnabledLeft:boolean;
begin
   SoundEnabledLeft:=false;
   if(click_type=pct_left)then
     if(iActOn(action))then
     begin
        SoundEnabledLeft:=iActEnabled(action);
        if(SoundEnabledLeft)
        then clickSound^:=snd_click
        else clickSound^:=snd_cant_order[r_hell];
     end;
end;
begin
   if(action=0)then exit;

   clickSound^:=nil;

   lbrush:=m_brush;
   case action of
   iAct_SProd1..
   iAct_SProd24           : if(ui_GameControlsEnabled)then
                            begin
                               u:=action-iAct_SProd1;
                               if(0<=u)and(u<=ui_ButtonsNum)then
                                 with g_gplayers[LocalPlayer] do
                                   case ui_tab of
                                   tab_buildings: case click_type of
                                                  pct_left : if(SoundOn)then m_brush:=ui_panel_uids[race,ui_tab,u];
                                                  end;
                                   tab_units    : case click_type of
                                                  pct_left : if(SoundOn)then PlayerSendOrder(co_sunit   ,0,ui_cam_cx,ui_cam_cy,ui_panel_uids[race,ui_tab,u],uo_corder,LocalPlayer);
                                                  pct_right: if(SoundOn)then PlayerSendOrder(co_cunit   ,0,ui_cam_cx,ui_cam_cy,ui_panel_uids[race,ui_tab,u],uo_corder,LocalPlayer);
                                                  end;
                                   tab_upgrades : case click_type of
                                                  pct_left : if(SoundOn)then PlayerSendOrder(co_supgrade,0,ui_cam_cx,ui_cam_cy,ui_panel_uids[race,ui_tab,u],uo_corder,LocalPlayer);
                                                  pct_right: if(SoundOn)then PlayerSendOrder(co_cupgrade,0,ui_cam_cx,ui_cam_cy,ui_panel_uids[race,ui_tab,u],uo_corder,LocalPlayer);
                                                  end;
                                   end;
                            end;
   iAct_Control_USelBase  : case click_type of
                            pct_left : if(SoundEnabled)then units_SelectGroup(false,254);
                            pct_Dleft: if(SoundEnabled)then ui_Camera_MoveToGroup(@ui_group_f1);
                            end;
   iAct_Control_USelArmy  : case click_type of
                            pct_left : if(SoundEnabled)then units_SelectGroup(false,255);
                            pct_Dleft: if(SoundEnabled)then ui_Camera_MoveToGroup(@ui_group_f2);
                            end;

   iAct_Control_UAbility1 : if(click_type=pct_left)and(ui_uibtn_sabilityu<>nil)then
                              if(SoundOn)then
                                with ui_uibtn_sabilityu^ do
                                  if(not GameLogBits2Message(LocalPlayer,uid^.uid_ability    ,lmt_argt_ability,unit_sability(ui_uibtn_sabilityu,true),x,y))then
                                    PlayerSendOrder(co_sability,0,ui_cam_cx,ui_cam_cy,uid^.uid_ability,uo_corder,LocalPlayer);
   iAct_Control_UAbility2 : if(click_type=pct_left)and(ui_uibtn_pabilityu<>nil)then
                              if(SoundOn)then
                                with ui_uibtn_pabilityu^ do
                                  if(not GameLogBits2Message(LocalPlayer,uid^.uid_ability    ,lmt_argt_ability,unit_pability(ui_uibtn_pabilityu,0,0,0,true),x,y))then
                                    m_brush :=co_pability;
   iAct_Control_Rebuild   : if(click_type=pct_left)and(ui_uibtn_rebuildu <>nil)then
                              if(SoundOn)then
                                with ui_uibtn_rebuildu^ do
                                  if(not GameLogBits2Message(LocalPlayer,uid^.uid_rebuild_uid,lmt_argt_unit   ,unit_rebuild(ui_uibtn_rebuildu,true),x,y))then
                                    PlayerSendOrder(co_rebuild,0,ui_cam_cx,ui_cam_cy,uid^.uid_rebuild_uid,uo_corder,LocalPlayer);

   iAct_InGamePause       : if(SoundEnabledLeft)then GamePauseToggle(false);
   iAct_InGameMenu        : if(SoundEnabledLeft)then GameOpenMenu;

   iAct_Replay_Fast       : if(SoundEnabledLeft)then sys_uncappedFPS:=not sys_uncappedFPS;
   iAct_Replay_Pause      : if(SoundEnabledLeft)then replay_Pause(false);
   iAct_Replay_Back2      : if(SoundEnabledLeft)then replay_SetPlayPosition(      g_tick -(fr_fps1*2 )+1,-1     ,false);
   iAct_Replay_Back10     : if(SoundEnabledLeft)then replay_SetPlayPosition(      g_tick -(fr_fps1*10)+1,-1     ,false);
   iAct_Replay_Back60     : if(SoundEnabledLeft)then replay_SetPlayPosition(      g_tick -(fr_fps1*60)+1,-1     ,false);
   iAct_Replay_Forward2   : if(SoundEnabledLeft)then replay_SetPlayPosition(int64(g_tick)+(fr_fps1*2 )+1,fr_fps1,false);
   iAct_Replay_Forward10  : if(SoundEnabledLeft)then replay_SetPlayPosition(int64(g_tick)+(fr_fps1*10)+1,fr_fps1,false);
   iAct_Replay_Forward60  : if(SoundEnabledLeft)then replay_SetPlayPosition(int64(g_tick)+(fr_fps1*60)+1,fr_fps1,false);
   iAct_Replay_POV        : if(SoundEnabledLeft)then rpls_POVRecorder:=not rpls_POVRecorder;
   iAct_Replay_Log        : if(SoundEnabledLeft)then rpls_showlog    :=not rpls_showlog;
   iAct_Replay_Fog        : if(SoundEnabledLeft)then ui_fog:=not ui_fog;
   iAct_Replay_PlayerAll  : if(SoundEnabledLeft)then UIPlayer:=255;
   iAct_Replay_Player0..
   iAct_Replay_Player7    : if(SoundEnabledLeft)then ui_SetPlayer(action-iAct_Replay_Player0,false);

   iAct_Observer_Fog      : if(SoundEnabledLeft)then ui_fog:=not ui_fog;
   iAct_Observer_PlayerAll: if(SoundEnabledLeft)then UIPlayer:=255;
   iAct_Observer_Player0..
   iAct_Observer_Player7  : if(SoundEnabledLeft)then ui_SetPlayer(action-iAct_Observer_Player0,false);

   iAct_Control_UAMove    : if(SoundEnabledLeft)then m_brush :=co_amove;
   iAct_Control_UAPatrol  : if(SoundEnabledLeft)then m_brush :=co_apatrol;
   iAct_Control_UMove     : if(SoundEnabledLeft)then m_brush :=co_move;
   iAct_Control_UPatrol   : if(SoundEnabledLeft)then m_brush :=co_patrol;
   iAct_Control_UAStop    : if(SoundEnabledLeft)then PlayerSendOrder(co_astand,0,0,0,0,uo_corder,LocalPlayer);
   iAct_Control_UStop     : if(SoundEnabledLeft)then PlayerSendOrder(co_stand ,0,0,0,0,uo_corder,LocalPlayer);
   iAct_Control_UProdCncl : if(SoundEnabledLeft)then
                              with g_gplayers[LocalPlayer] do
                                if(s_barracks>0)
                                or(s_smiths  >0)
                                then PlayerSendOrder(co_pcancle,0,ui_cam_cx,ui_cam_cy,255,uo_corder,LocalPlayer)
                                else
                                  case ui_tab of
                                  tab_units    : PlayerSendOrder(co_cunit   ,0,ui_cam_cx,ui_cam_cy,255,uo_corder,LocalPlayer);
                                  tab_upgrades : PlayerSendOrder(co_cupgrade,0,ui_cam_cx,ui_cam_cy,255,uo_corder,LocalPlayer);
                                  end;
   iAct_Control_UDestroy  : if(SoundEnabledLeft)then PlayerSendOrder(co_destroy,0,0,0,0,uo_corder,LocalPlayer);
   end;

   if(lbrush<>m_brush)then
     mouse_BrushCheck(true);
end;

procedure ui_ControlPanel_click(click_type:TTabBTNClickType;clickSound:pPTSoundSet);
begin
   case m_btnN of
0..ui_ButtonsNum: case ui_tab of
                  tab_Buildings,
                  tab_Units,
                  tab_Upgrades : ui_ExecInGameAction(iAct_SProd1+m_BtnN                          ,click_type,clickSound);
                  tab_Controls : ui_ExecInGameAction(ui_panel_CTabIActs[ui_ControlTabType,m_BtnN],click_type,clickSound);
                  end;

   else
   end;
end;

procedure WindowEvents;
var i:byte;
begin
   for i:=0 to 255 do inputAction_TimerProc(i);

   if(k_LastChar_t<0)
   then k_LastChar_t:=0
   else
     if(0<k_LastChar_t)and(k_LastChar_t<k_LastChar_t.MaxValue)then k_LastChar_t+=1;

   k_KeyboardString:='';

   if(k_LastChar_t>k_LastCharStuckDelay)then
     if(length(k_KeyboardString)<255)then k_KeyboardString+=k_LastChar;

   while (SDL_PollEvent(sys_EVENT)>0) do
     case (sys_EVENT^.type_) of
      SDL_QUITEV         : GameCycle:=false;
      SDL_VIDEORESIZE    : begin
                           vid_vw:=max2i(vid_minw,sys_EVENT^.resize.w);menu_ResolutionWi:=vid_vw;
                           vid_vh:=max2i(vid_minh,sys_EVENT^.resize.h);menu_ResolutionWi:=vid_vh;

                           vid_MakeScreen;
                           theme_map_pTerrain:=255;
                           gfx_MapMakeTerrain;
                           menu_update:=true;
                           end;
      SDL_MOUSEMOTION    : begin
                              if(m_DragCamMove)and(not MainMenu)and(G_Started)then
                              begin
                                 ui_cam_x-=sys_EVENT^.motion.x-mouse_x;
                                 ui_cam_y-=sys_EVENT^.motion.y-mouse_y;
                                 ui_Camera_Bounds;
                              end;
                              mouse_x:=sys_EVENT^.motion.x;
                              mouse_y:=sys_EVENT^.motion.y;
                           end;
      SDL_MOUSEBUTTONUP   : input_ActionKeyProc(sys_event^.button.button ,ikt_mouseb  ,false);
      SDL_MOUSEBUTTONDOWN : case sys_event^.button.button of
      SDL_BUTTON_WHEELDOWN,
      SDL_BUTTON_WHEELUP  : input_ActionKeyProc(sys_event^.button.button ,ikt_mousew  ,true);
                       else input_ActionKeyProc(sys_event^.button.button ,ikt_mouseb  ,true );
                            end;
      SDL_KEYUP           : begin
                            input_ActionKeyProc(sys_event^.key.keysym.sym,ikt_keyboard,false);
                            k_LastChar_t:=-1;
                            end;
      SDL_KEYDOWN         : begin
                            input_ActionKeyProc(sys_event^.key.keysym.sym,ikt_keyboard,true );
                            k_LastChar_t:= 1;
                            k_LastChar  :=Widechar(sys_EVENT^.key.keysym.unicode);
                            if(length(k_KeyboardString)<255)then
                              if(k_LastChar in CharSetAll)then
                                k_KeyboardString+=k_LastChar;
                            end;
     else
     end;
end;

procedure ui_PointClick;
var u:integer;
begin
   u:=mouse_BrushTarget(mouse_map_x,mouse_map_y,co_empty);
   if(u>0)then ui_UpdateLastSelectedUnit(u);
end;

procedure GameControlsMouse;
var
   u,bx,by:integer;
clickSound:PTSoundSet;
begin
   clickSound:=nil;
   if(ui_ControlPanelPos<2)then  // vertical
   begin
      u:=mouse_x-ui_UIPanelX;bx:=u div ui_ButtonW1;if(u<0)then bx-=1;
      u:=mouse_y-ui_UIPanelY;by:=u div ui_ButtonW1;if(u<0)then by-=1;
   end
   else
   begin
      u:=mouse_y-ui_UIPanelY;bx:=u div ui_ButtonW1;if(u<0)then bx-=1;
      u:=mouse_x-ui_UIPanelX;by:=u div ui_ButtonW1;if(u<0)then by-=1;
   end;

   m_focus:=mf_map;
   if (0<=bx)and(bx<ui_CtrlPanelBW)
   and(0<=by)and(by<=ui_CtrlPanelBL)then
     if(by<ui_CtrlPanelBW)
     then m_focus:=mf_MiniMap
     else
       if(by=ui_CtrlPanelBW)
       then m_focus:=mf_Tabs
       else
         if(by=ui_CtrlPanelBL)
         then m_focus:=mf_MenuPause
         else m_focus:=mf_CtrlPanel;
   case m_focus of
   mf_Map,
   mf_MiniMap  : m_btnN:=-1;
   mf_Tabs     : if(ui_ControlPanelPos<2)
                 then begin u:=mouse_x-ui_UIPanelX;m_btnN:=u div ui_TabButtonW;if(u<0)then m_btnN-=1;end
                 else begin u:=mouse_y-ui_UIPanelY;m_btnN:=u div ui_TabButtonW;if(u<0)then m_btnN-=1;end;
   mf_CtrlPanel: begin
                 by-=4;
                 m_btnN:=(by*ui_CtrlPanelBW)+(bx mod ui_CtrlPanelBW);
                 end;
   mf_MenuPause: m_btnN:=bx;
   end;
   if(m_focus=mf_MiniMap)then
   begin
      mouse_map_x:=round((mouse_x-ui_UIPanelX)/map_mmcx);
      mouse_map_y:=round((mouse_y-ui_UIPanelY)/map_mmcx);
   end
   else
   begin
      mouse_map_x:=mouse_x+ui_cam_x;
      mouse_map_y:=mouse_y+ui_cam_y;
   end;

   mouse_BrushCheck(false);

   m_UnitTargetN:=0;
   m_UnitTargetP:=nil;
   if(mouse_select_xs0=NOTSET)
   or(CheckSimpleClick(mouse_select_xs0,mouse_select_ys0,mouse_map_x,mouse_map_y))then
   begin
      m_UnitTargetN:=mouse_BrushTarget(mouse_map_x,mouse_map_y,m_brush);
      if(m_UnitTargetN>0)then
        m_UnitTargetP:=g_punits[m_UnitTargetN];
   end;

   if(InputActionPressed(iact_MLB))then                // LMB down
     case m_focus of
     mf_map      : case m_brush of
                   co_empty  : if(m_UnitTargetP<>nil)and( InputAction(iact_Control)or InputActionDPressed(iact_MLB) )then
                               begin
                                  if(m_UnitTargetP^.playeri=UIPlayer)then
                                    units_SelectRect(InputAction(iact_Shift),ui_cam_x,ui_cam_y, ui_cam_x+ui_cam_w,ui_cam_y+ui_cam_h,m_UnitTargetP^.uidi);
                               end
                               else
                               begin
                                  if(m_UnitTargetP<>nil)then
                                    if(d_UpdateUIPlayer(m_UnitTargetN))then exit;
                                  mouse_select_xs0:=mouse_map_x;
                                  mouse_select_ys0:=mouse_map_y;
                               end;
                   1..255    : if(m_brushc=c_lime)
                               then PlayerSendOrder(m_brushx,m_brushy,0,0,byte(m_brush), uo_build  ,LocalPlayer)
                               else GameLogBits2Message(LocalPlayer,byte(m_brush),lmt_argt_unit,ureq_place,mouse_map_x,mouse_map_y);
                   co_pability,
                   co_move,
                   co_amove,
                   co_patrol,
                   co_apatrol: ui_MBrush2Command(m_brushx,m_brushy,m_UnitTargetN);
                   co_mmark  : MapMarker(mouse_map_x,mouse_map_y);
                   end;
     mf_minimap  : case m_brush of
                   co_pability,
                   co_move,
                   co_amove,
                   co_patrol,
                   co_apatrol: ui_MBrush2Command(m_brushx,m_brushy,m_UnitTargetN);
                   co_mmark  : MapMarker(mouse_map_x,mouse_map_y);
                   else        if(not rpls_POVRecorder)then m_mmap_move:=true;
                   end;
     mf_tabs     : if(0<=m_btnN)and(m_btnN<4)then
                   begin
                      ui_tab:=byte(m_btnN);
                      clickSound:=snd_click;
                   end;
     mf_CtrlPanel: ui_ControlPanel_click(pct_left,@clickSound);     // panel
     mf_MenuPause: case m_btnN of
                   0 : ui_ExecInGameAction(iAct_InGameMenu ,pct_left,@clickSound);
                   2 : ui_ExecInGameAction(iAct_InGamePause,pct_left,@clickSound);
                   end;
     end;

   if(InputActionReleased(iact_MLB))then  // LMB up
   begin
      m_mmap_move:=false;

      if(mouse_select_xs0<>NOTSET)then //select
      begin
         units_SelectRect(InputAction(iact_Shift),mouse_select_xs0,mouse_select_ys0,mouse_map_x,mouse_map_y,255);
         if(G_Status=gs_running)and(rpls_pstate<rpls_read)then
           if(CheckSimpleClick(mouse_select_xs0,mouse_select_ys0,mouse_map_x,mouse_map_y))then ui_PointClick;

         mouse_select_xs0:=NOTSET;
      end;
   end;

   if(m_mmap_move)and(mouse_select_xs0=NOTSET)then
   begin
      ui_Camera_MoveToPoint(trunc((mouse_x-ui_UIPanelX)/map_mmcx), trunc((mouse_y-ui_UIPanelY)/map_mmcx));
      ui_Camera_Bounds;
   end;

 //  if(k_mr=2)then effect_add(mouse_map_x,mouse_map_y-50,10000,UID_Pain);
   {if(ks_mright=1)and(ks_ctrl>2)then
   begin
      u:=_whoInPoint(mouse_map_x,mouse_map_y,0);
      if(u>0)then
       with g_units[u] do hits:=hits div 2;
   end; }

   if(InputActionPressed(iact_MRB))then            // RMB down
     if(m_brush<>co_empty)
     then m_brush:=co_empty
     else
       case m_focus of
       mf_map,
       mf_minimap  : ui_MBrush2Command(mouse_map_x,mouse_map_y,m_UnitTargetN);
       mf_CtrlPanel: ui_ControlPanel_click(pct_right,@clickSound);     // panel
       end;

   if(InputActionPressed(iact_MMB))then            // MMB down
     case m_focus of
     mf_map      : m_DragCamMove:=true;
     mf_minimap  : ;
     mf_CtrlPanel: ;
     end;

   if(InputActionReleased(iact_MMB))then           // MMB up
     m_DragCamMove:=false;

   if(clickSound<>nil)then
   begin
      SoundPlayUI(clickSound);
      ui_update_now:=true;
   end;
end;

procedure GameControlsCameraMove;
var vx,vy:integer;
begin
   vx:=ui_cam_x;
   vy:=ui_cam_y;

   if(ui_MouseScroll)then
   begin
      if(mouse_x<ui_vmb_x0)then ui_cam_x-=ui_CamSpeed;
      if(mouse_y<ui_vmb_y0)then ui_cam_y-=ui_CamSpeed;
      if(mouse_x>ui_vmb_x1)then ui_cam_x+=ui_CamSpeed;
      if(mouse_y>ui_vmb_y1)then ui_cam_y+=ui_CamSpeed;
   end;

   if(InputAction(iact_Up   ))then ui_cam_y-=ui_CamSpeed;
   if(InputAction(iact_left ))then ui_cam_x-=ui_CamSpeed;
   if(InputAction(iact_down ))then ui_cam_y+=ui_CamSpeed;
   if(InputAction(iact_right))then ui_cam_x+=ui_CamSpeed;

   if(vx<>ui_cam_x)or(vy<>ui_cam_y)then ui_Camera_Bounds;
end;

procedure test_nullupgr(playeri:byte);
var i:byte;
begin
   with g_gplayers[playeri] do
     for i:=1 to 255 do
       upgr[i]:=0;
end;

procedure GameControlsKeyboard;
var
act,k:byte;
clickSound:boolean;
begin
   clickSound:=false;
   if(not m_DragCamMove)and(not rpls_POVRecorder)then GameControlsCameraMove;

   // Chat
   if(rpls_pstate=rpls_read)or(net_status=ns_none)
   then ui_InGameChat:=0
   else
   begin
      if(InputActionPressed(iAct_InGameChat))then
        if(ui_InGameChat>0)then
        begin
           if(length(net_chat_str)>0)then
           begin
              case ui_InGameChat of
              chat_all   : ui_InGameChat:=255;
              chat_allies: if(PlayerGetAlliesByte(LocalPlayer,false)>0)then
                             ui_InGameChat:=PlayerGetAlliesByte(LocalPlayer,true);
              else         ui_InGameChat:=0;
              end;

              if(ui_InGameChat>0)then
                if(net_status=ns_client)
                then net_send_chat(            ui_InGameChat,net_chat_str)
                else GameLogChat  (LocalPlayer,ui_InGameChat,net_chat_str);
              net_chat_str:='';
           end;
           ui_InGameChat:=0;
        end
        else
          if(PlayerGetAlliesByte(LocalPlayer,false)>0)
          then ui_InGameChat:=chat_allies
          else ui_InGameChat:=chat_all;
      if(InputActionPressed(iAct_InGameChatAllies))then
        if(ui_InGameChat=0)then
          if(PlayerGetAlliesByte(LocalPlayer,false)>0)then ui_InGameChat:=chat_allies;
      if(InputActionPressed(iAct_InGameChatAll   ))then
        if(ui_InGameChat=0)then ui_InGameChat:=chat_all;
      // Chat text input
      if(ui_InGameChat>0)then
        if(length(k_KeyboardString)>0)or(InputActionPressed(iAct_backspace))then
          net_chat_str:=StringApplyInput(net_chat_str,CharSetCommon,MaxChatStringLength,nil);
   end;

   // Escape
   if(InputActionPressed(iact_Esc))then
     if(ui_InGameChat>0)then
     begin
        ui_InGameChat :=0;
        net_chat_str:='';
     end;

   // tab
   if(InputActionPressed(iAct_Tab  ))then
   begin
      ui_tab+=1;
      ui_tab:=ui_tab mod 4;
      clickSound:=true;
   end;

   // Menu
   if(ui_InGameChat=0)then
     if(InputActionPressed(iAct_InGameMenu))then
       ui_ExecInGameAction(iAct_InGameMenu,pct_left,@clickSound);

     // pause
   if(InputActionPressed(iAct_InGamePause))then
     ui_ExecInGameAction(iAct_InGamePause,pct_left,@clickSound);

   // other ngame actions
   if(ui_InGameChat=0)then
   begin
      // Test mode
      if(TestMode>0)and(net_status=ns_none)then
      begin
         if(InputActionPressed(iAct_test_FastTime    ))then sys_uncappedFPS:=not sys_uncappedFPS;
         {$IFDEF DEBUG0}
         if(InputActionPressed(iAct_test_InstaProd   ))then test_InstaProd:=not test_InstaProd;
         {$ENDIF}
         if(InputActionPressed(iAct_test_ToggleAI    ))then with g_gplayers[LocalPlayer] do if(state=ps_human     )then state:=ps_AI         else state:=ps_human;
         if(InputActionPressed(iAct_test_iddqd       ))then with g_gplayers[LocalPlayer] do if(upgr[upgr_invuln]=0)then upgr[upgr_invuln]:=1 else upgr[upgr_invuln]:=0;
         if(InputActionPressed(iAct_test_FogToggle   ))then ui_fog  :=not ui_fog;
         if(InputActionPressed(iAct_test_DrawToggle  ))then vid_draw:=not vid_draw;
         if(InputActionPressed(iAct_test_NullUpgrades))then test_nullupgr(LocalPlayer);
         if(InputActionPressed(iAct_test_BePlayer0   ))then LocalPlayer:=0;
         if(InputActionPressed(iAct_test_BePlayer1   ))then LocalPlayer:=1;
         if(InputActionPressed(iAct_test_BePlayer2   ))then LocalPlayer:=2;
         if(InputActionPressed(iAct_test_BePlayer3   ))then LocalPlayer:=3;
         if(InputActionPressed(iAct_test_BePlayer4   ))then LocalPlayer:=4;
         if(InputActionPressed(iAct_test_BePlayer5   ))then LocalPlayer:=5;
         if(InputActionPressed(iAct_test_BePlayer6   ))then LocalPlayer:=6;
         if(InputActionPressed(iAct_test_BePlayer7   ))then LocalPlayer:=7;
         if(InputActionPressed(iAct_test_debug0      ))then writeln(MenuBack(false,true));
         if(InputActionPressed(iAct_test_debug1      ))then ;
      end;

      if(g_status=gs_running)then
      begin

         // To last event
         if(InputActionPressed(iAct_LastEvent))then
         begin
            ui_Camera_ToLastEvent;
            clickSound:=true;
         end;

         // Groups
         for k:=iAct_USetGroup0 to iAct_USetGroup9 do if(InputActionPressed(k))then units_Grouping   (false,k-iAct_USetGroup0);
         for k:=iAct_UAddGroup0 to iAct_UAddGroup9 do if(InputActionPressed(k))then units_Grouping   (true ,k-iAct_UAddGroup0);
         for k:=iAct_UASlGroup0 to iAct_UASlGroup9 do if(InputActionPressed(k))then units_SelectGroup(true ,k-iAct_UASlGroup0);
         for k:=iAct_USelGroup0 to iAct_USelGroup9 do
           if(InputActionDPressed(k))and(k<>iAct_USelGroup0)
           then ui_Camera_MoveToGroup(@ui_group_d[k-iAct_USelGroup0])
           else
             if(InputActionPressed(k))
             then units_SelectGroup(false,k-iAct_USelGroup0);

         // Controls tab actions
         for k:=0 to ui_ButtonsNum do
         begin
            act:=ui_panel_CTabIActs[ui_ControlTabType,k];
            if(InputActionPressed(act))then
              ui_ExecInGameAction(act,pct_left,@clickSound);
         end;
         if(InputActionDPressed(iAct_Control_USelBase))then ui_Camera_MoveToGroup(@ui_group_f1);
         if(InputActionDPressed(iAct_Control_USelArmy))then ui_Camera_MoveToGroup(@ui_group_f2);

         // Production hotkeys
         case ui_tab of
         tab_buildings,
         tab_units,
         tab_upgrades : for k:=0 to ui_ButtonsNum do
                          if(InputActionPressed(iAct_SProd1+k))then
                            ui_ExecInGameAction(iAct_SProd1+k,pct_left,@clickSound);
         end;
      end;
   end;

   if(clickSound)then
   begin
      SoundPlayUI(snd_click);
      ui_update_now:=true;
   end;
end;


procedure GameInput;
begin
   WindowEvents;

   if(InputActionPressed(iact_Screenshot))then gfx_MakeScreenshot;

   if(MainMenu)then
   begin
      menu_Controls;
   end
   else
   begin
      GameControlsKeyboard;
      GameControlsMouse;
      ui_EnableControlActs;
   end;

   // rebuild menu
   if(menu_update)then
   begin
      menu_Rebuild;
      menu_update:=false;
      menu_redraw:=true;

      if(menu_items[menu_ItemSelected].mi_state<as_enabled)then  // editing cancel
      begin
         case menu_ItemSelected of
         mi_Map_Seed        : menu_mseed:=c2s(map_seed);
         mi_SV_ResolutionW  : menu_ResolutionWi :=vid_vw;
         mi_SV_ResolutionH  : menu_ResolutionHi :=vid_vh;
         mi_MP_ServerPort   : menu_ServerPort   :=w2s(net_ServerPort);
         mi_MP_ClientAddress: menu_ClientAddress:=c2ip(net_cl_svip)+':'+w2s(swap(net_cl_svport));
         end;
         menu_ItemSelected:=0;
      end;
   end;
end;



