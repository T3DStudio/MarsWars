
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

   input_SetAction(iAct_Delete            ,ikt_keyboard,0           ,SDLK_Delete      );
   input_SetAction(iAct_Tab               ,ikt_keyboard,0           ,SDLK_Tab         );
   input_SetAction(iAct_ScreenShot        ,ikt_keyboard,0           ,SDLK_Print       );
   input_SetAction(iAct_LastEvent         ,ikt_keyboard,0           ,SDLK_Space       );

   input_SetAction(iAct_ToggleWindowed    ,ikt_keyboard,iAct_Alt    ,SDLK_RETURN      );


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

   input_SetAction(iAct_UAddGroup1        ,ikt_keyboard,iAct_Alt    ,SDLK_1           );
   input_SetAction(iAct_UAddGroup2        ,ikt_keyboard,iAct_Alt    ,SDLK_2           );
   input_SetAction(iAct_UAddGroup3        ,ikt_keyboard,iAct_Alt    ,SDLK_3           );
   input_SetAction(iAct_UAddGroup4        ,ikt_keyboard,iAct_Alt    ,SDLK_4           );
   input_SetAction(iAct_UAddGroup5        ,ikt_keyboard,iAct_Alt    ,SDLK_5           );
   input_SetAction(iAct_UAddGroup6        ,ikt_keyboard,iAct_Alt    ,SDLK_6           );
   input_SetAction(iAct_UAddGroup7        ,ikt_keyboard,iAct_Alt    ,SDLK_7           );
   input_SetAction(iAct_UAddGroup8        ,ikt_keyboard,iAct_Alt    ,SDLK_8           );
   input_SetAction(iAct_UAddGroup9        ,ikt_keyboard,iAct_Alt    ,SDLK_9           );

   input_SetAction(iAct_UASlGroup1        ,ikt_keyboard,iAct_shift  ,SDLK_1           );
   input_SetAction(iAct_UASlGroup2        ,ikt_keyboard,iAct_shift  ,SDLK_2           );
   input_SetAction(iAct_UASlGroup3        ,ikt_keyboard,iAct_shift  ,SDLK_3           );
   input_SetAction(iAct_UASlGroup4        ,ikt_keyboard,iAct_shift  ,SDLK_4           );
   input_SetAction(iAct_UASlGroup5        ,ikt_keyboard,iAct_shift  ,SDLK_5           );
   input_SetAction(iAct_UASlGroup6        ,ikt_keyboard,iAct_shift  ,SDLK_6           );
   input_SetAction(iAct_UASlGroup7        ,ikt_keyboard,iAct_shift  ,SDLK_7           );
   input_SetAction(iAct_UASlGroup8        ,ikt_keyboard,iAct_shift  ,SDLK_8           );
   input_SetAction(iAct_UASlGroup9        ,ikt_keyboard,iAct_shift  ,SDLK_9           );

   input_SetAction(iAct_USelGroup1        ,ikt_keyboard,0           ,SDLK_1           );
   input_SetAction(iAct_USelGroup2        ,ikt_keyboard,0           ,SDLK_2           );
   input_SetAction(iAct_USelGroup3        ,ikt_keyboard,0           ,SDLK_3           );
   input_SetAction(iAct_USelGroup4        ,ikt_keyboard,0           ,SDLK_4           );
   input_SetAction(iAct_USelGroup5        ,ikt_keyboard,0           ,SDLK_5           );
   input_SetAction(iAct_USelGroup6        ,ikt_keyboard,0           ,SDLK_6           );
   input_SetAction(iAct_USelGroup7        ,ikt_keyboard,0           ,SDLK_7           );
   input_SetAction(iAct_USelGroup8        ,ikt_keyboard,0           ,SDLK_8           );
   input_SetAction(iAct_USelGroup9        ,ikt_keyboard,0           ,SDLK_9           );

   input_SetAction(iAct_Control_UAbility1 ,ikt_keyboard,0           ,SDLK_Q           );
   input_SetAction(iAct_Control_UAbility2 ,ikt_keyboard,0           ,SDLK_W           );
   input_SetAction(iAct_Control_UAbility3 ,ikt_keyboard,0           ,SDLK_E           );
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
   input_SetAction(iAct_Control_MarkLook  ,ikt_keyboard,0           ,SDLK_F5          );
   input_SetAction(iAct_Control_MarkAttack,ikt_keyboard,0           ,SDLK_F6          );
   input_SetAction(iAct_Control_ToggleRec ,ikt_keyboard,0           ,SDLK_F10         );


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
   {$IFDEF TESTMODE}
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
   input_SetAction(iAct_test_AddHellPower ,ikt_keyboard,iAct_Control,SDLK_UP          );
   input_SetAction(iAct_test_AddUACLoot   ,ikt_keyboard,iAct_Alt    ,SDLK_UP          );
   input_SetAction(iAct_test_debug0       ,ikt_keyboard,0           ,SDLK_KP8         );
   input_SetAction(iAct_test_debug1       ,ikt_keyboard,0           ,SDLK_KP9         );
   {$ENDIF}
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
   input_SetAction(iAct_Observer_POV      ,ikt_keyboard,0           ,SDLK_W           );
   input_SetAction(iAct_Observer_PlayerAll,ikt_keyboard,0           ,SDLK_E           );
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

   // with depends
   for i:=0 to 255 do
     with input_actions[i] do
       if (ik_type =ktype )
       and(ik_value=kvalue)then
         if(ik_depend>0)then
         begin
            case down of
            false : if(ik_kstate=ks_pressed)
                    then ik_kstate:=ks_both
                    else ik_kstate:=ks_released;
            true  : if(ik_kstate=ks_none)and(InputAction(ik_depend))then
                    begin
                    ik_kstate:=ks_pressed;
                    exit;
                    end;
            end;
         end;

   // no depends
   for i:=0 to 255 do
     with input_actions[i] do
       if((ik_type=ktype)and(ik_value=kvalue))
       or(i=iAct_any)then
         if(ik_depend=0)and(ik_kstate<>ks_both)then
           case down of
           false : if(ik_kstate=ks_pressed)
                   then ik_kstate:=ks_both
                   else ik_kstate:=ks_released;
           true  : if(ik_kstate=ks_none)then
                   ik_kstate:=ks_pressed;
           end;
end;

procedure inputAction_TimerProc(keyi:byte);
begin
   with input_actions[keyi] do
   begin
      case ik_kstate of
      ks_none    :;
      ks_pressed : if(ik_type=ikt_mousew)
                   then ik_kstate:=ks_none
                   else
                   begin
                      ik_kstate:=ks_hold;
                      ik_timer_pressed:=1;
                   end;
      ks_released: begin
                      ik_kstate:=ks_none;
                      if(ik_timer_twice<=0)then
                        ik_timer_twice:=kt_TwiceDelay;
                   end;
      ks_both    : ik_kstate:=ks_none;
      ks_hold    : if(ik_timer_pressed<ik_timer_pressed.MaxValue)then
                     ik_timer_pressed+=1;
      end;
      if(ik_timer_twice>0)then ik_timer_twice-=1;
   end;
end;

////////////////////////////////////////////////////////////////////////////////
//
//    UI INPUT
//

procedure ui_InitControlPanelBTNActions;
var i:byte;
function MPos(apos:byte):byte;
var step:byte;
begin
   MPos:=0;
   case ui_ControlPanelPos of
   cpp_left,
   cpp_right : MPos:=apos;
   cpp_top,
   cpp_bottom: begin
               step:=(apos div ui_CtrlPanelBlock)*ui_CtrlPanelBlock;
               apos:=apos mod ui_CtrlPanelBlock;
               apos:=ui_CtrlPanelBW*(apos mod ui_CtrlPanelBW)+(apos div ui_CtrlPanelBW);
               MPos:=step+apos;
               case MPos of
               24: MPos:=20; //20
               25: MPos:=23;
               end;
               end;
   end;
   if(MPos>ui_ButtonsNum)then MPos:=ui_ButtonsNum;
end;

begin
   FillChar(ui_panel_CTabIActs,SizeOf(ui_panel_CTabIActs),0);
   FillChar(ui_panel_PTabIActs,SizeOf(ui_panel_PTabIActs),0);

   for i:=0 to ui_ButtonsNum do
     ui_panel_PTabIActs[MPos(i)]:=iAct_SProd1+i;

   ui_panel_CTabIActs[tcc_controls,MPos(0 )]:=iAct_Control_UAbility1;
   ui_panel_CTabIActs[tcc_controls,MPos(1 )]:=iAct_Control_UAbility2;
   ui_panel_CTabIActs[tcc_controls,MPos(2 )]:=iAct_Control_UAbility3;
   ui_panel_CTabIActs[tcc_controls,MPos(3 )]:=iAct_Control_UAMove;
   ui_panel_CTabIActs[tcc_controls,MPos(4 )]:=iAct_Control_UAStop;
   ui_panel_CTabIActs[tcc_controls,MPos(5 )]:=iAct_Control_UAPatrol;
   ui_panel_CTabIActs[tcc_controls,MPos(6 )]:=iAct_Control_UMove;
   ui_panel_CTabIActs[tcc_controls,MPos(7 )]:=iAct_Control_UStop;
   ui_panel_CTabIActs[tcc_controls,MPos(8 )]:=iAct_Control_UPatrol;
   ui_panel_CTabIActs[tcc_controls,MPos(9 )]:=iAct_Control_UProdCncl;
   ui_panel_CTabIActs[tcc_controls,MPos(10)]:=iAct_Control_UDestroy;
   ui_panel_CTabIActs[tcc_controls,MPos(12)]:=iAct_Control_USelBase;
   ui_panel_CTabIActs[tcc_controls,MPos(13)]:=iAct_Control_USelArmy;
   ui_panel_CTabIActs[tcc_controls,MPos(15)]:=iAct_Control_MarkLook;
   ui_panel_CTabIActs[tcc_controls,MPos(16)]:=iAct_Control_MarkAttack;

   ui_panel_CTabIActs[tcc_replay  ,MPos(0 )]:=iAct_Replay_Fast;
   ui_panel_CTabIActs[tcc_replay  ,MPos(1 )]:=iAct_Replay_Pause;
   ui_panel_CTabIActs[tcc_replay  ,MPos(3 )]:=iAct_Replay_Back60;
   ui_panel_CTabIActs[tcc_replay  ,MPos(4 )]:=iAct_Replay_Back10;
   ui_panel_CTabIActs[tcc_replay  ,MPos(5 )]:=iAct_Replay_Back2;
   ui_panel_CTabIActs[tcc_replay  ,MPos(6 )]:=iAct_Replay_Forward60;
   ui_panel_CTabIActs[tcc_replay  ,MPos(7 )]:=iAct_Replay_Forward10;
   ui_panel_CTabIActs[tcc_replay  ,MPos(8 )]:=iAct_Replay_Forward2;
   ui_panel_CTabIActs[tcc_replay  ,MPos(9 )]:=iAct_Replay_POV;
   ui_panel_CTabIActs[tcc_replay  ,MPos(10)]:=iAct_Replay_Log;
   ui_panel_CTabIActs[tcc_replay  ,MPos(11)]:=iAct_Replay_Fog;
   ui_panel_CTabIActs[tcc_replay  ,MPos(12)]:=iAct_Replay_PlayerAll;
   ui_panel_CTabIActs[tcc_replay  ,MPos(13)]:=iAct_Replay_Player0;
   ui_panel_CTabIActs[tcc_replay  ,MPos(14)]:=iAct_Replay_Player1;
   ui_panel_CTabIActs[tcc_replay  ,MPos(15)]:=iAct_Replay_Player2;
   ui_panel_CTabIActs[tcc_replay  ,MPos(16)]:=iAct_Replay_Player3;
   ui_panel_CTabIActs[tcc_replay  ,MPos(17)]:=iAct_Replay_Player4;
   ui_panel_CTabIActs[tcc_replay  ,MPos(18)]:=iAct_Replay_Player5;
   ui_panel_CTabIActs[tcc_replay  ,MPos(19)]:=iAct_Replay_Player6;
   ui_panel_CTabIActs[tcc_replay  ,MPos(20)]:=iAct_Replay_Player7;

   ui_panel_CTabIActs[tcc_observer,MPos(0 )]:=iAct_Observer_Fog;
   ui_panel_CTabIActs[tcc_observer,MPos(1 )]:=iAct_Observer_POV;
   ui_panel_CTabIActs[tcc_observer,MPos(2 )]:=iAct_Observer_PlayerAll;
   ui_panel_CTabIActs[tcc_observer,MPos(3 )]:=iAct_Observer_Player0;
   ui_panel_CTabIActs[tcc_observer,MPos(4 )]:=iAct_Observer_Player1;
   ui_panel_CTabIActs[tcc_observer,MPos(5 )]:=iAct_Observer_Player2;
   ui_panel_CTabIActs[tcc_observer,MPos(6 )]:=iAct_Observer_Player3;
   ui_panel_CTabIActs[tcc_observer,MPos(7 )]:=iAct_Observer_Player4;
   ui_panel_CTabIActs[tcc_observer,MPos(8 )]:=iAct_Observer_Player5;
   ui_panel_CTabIActs[tcc_observer,MPos(9 )]:=iAct_Observer_Player6;
   ui_panel_CTabIActs[tcc_observer,MPos(10)]:=iAct_Observer_Player7;
   ui_panel_CTabIActs[tcc_observer,MPos(12)]:=iAct_Control_MarkLook;
   ui_panel_CTabIActs[tcc_observer,MPos(13)]:=iAct_Control_MarkAttack;

end;

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

procedure ui_EnableControlActs;
var
ucl,act,
uid      :byte;
POVPlayer:PTPlayerGameData;
g_control:boolean;
ctabType :TTabControlContent;
begin
   g_control:=ui_GameControlsEnabled;
   ctabType :=ui_ControlTabType;

   if(UIPlayer<=LastPlayer)
   then POVPlayer:=@g_PlayersGame[UIPlayer]
   else POVPlayer:=nil;

   iActSetOnEnabled(iAct_InGamePause,Game_PauseToggle(true),true);
   iActSetOnEnabled(iAct_InGameMenu ,true                 ,true);

   // production actions
   for ucl in [iAct_SProd1..iAct_SProd24,
               iAct_Control_UAbility1..iAct_Control_UAbility3,
               iAct_Control_UAMove,
               iAct_Control_UAStop,
               iAct_Control_UAPatrol,
               iAct_Control_UMove,
               iAct_Control_UStop,
               iAct_Control_UPatrol,
               iAct_Control_UProdCncl,
               iAct_Control_UDestroy,
               iAct_Control_USelBase,
               iAct_Control_USelArmy,
               iAct_Control_MarkLook,
               iAct_Control_MarkAttack] do
     input_actions[ucl].ik_astate:=as_off;

   for ucl:=0 to ui_ButtonsNum do
   begin
      act:=ui_panel_PTabIActs[ucl];
      input_actions[act].ik_astate:=as_off;
      if(POVPlayer<>nil)then
        with POVPlayer^ do
        begin
           uid:=ui_panel_uids[race,ui_tab,act-iAct_SProd1];
           case ui_tab of
           tab_buildings: if(ui_PanelBTNUnit   (POVPlayer,uid))then iActSetDisabled(act,not g_control or(CheckUnitReqs   (POVPlayer,uid)>0)or not(uid in ui_bprod_possible));
           tab_units    : if(ui_PanelBTNUnit   (POVPlayer,uid))then iActSetDisabled(act,not g_control or(CheckUnitReqs   (POVPlayer,uid)>0)or(prod_unit_Now>=prod_unit_Max)or(ui_uprod_cur>=ui_uprod_max)or(ui_uprod_uid_max[uid]<=0));
           tab_upgrades : if(ui_PanelBTNUpgrade(POVPlayer,uid))then iActSetDisabled(act,not g_control or(CheckUpgradeReqs(POVPlayer,uid)>0)or(prod_upgr_Now>=prod_upgr_Max)or(prod_upgr_upid[uid]>=ui_pprod_upg_max[uid]));
           end;
        end;
   end;

   // unit controls
   iActSetOnEnabled(iAct_Control_MarkLook  ,((ctabType=tcc_Controls)or(ctabType=tcc_Observer))and(net_status<>ns_none), true );
   iActSetOnEnabled(iAct_Control_MarkAttack,((ctabType=tcc_Controls)or(ctabType=tcc_Observer))and(net_status<>ns_none), true );

   if(ctabType=tcc_Controls)and(g_control)then
   begin
      if(iActIfOn(iAct_Control_UAbility1,ui_PanelBTNAbility(ui_CommandercPU,1)))then
        with ui_CommandercPU^ do
        with uid^ do
          iActSetDisabled(iAct_Control_UAbility1,GameLog_ReqMsg(LocalPlayer,uid_ability1,lmt_argt_ability,unit_AbilityCheck(ui_CommandercPU,uid_ability1,false),x,y,true) );
      if(iActIfOn(iAct_Control_UAbility2,ui_PanelBTNAbility(ui_CommandercPU,2)))then
        with ui_CommandercPU^ do
        with uid^ do
          iActSetDisabled(iAct_Control_UAbility2,GameLog_ReqMsg(LocalPlayer,uid_ability2,lmt_argt_ability,unit_AbilityCheck(ui_CommandercPU,uid_ability2,false),x,y,true) );
      if(iActIfOn(iAct_Control_UAbility3,ui_PanelBTNAbility(ui_CommandercPU,3)))then
        with ui_CommandercPU^ do
        with uid^ do
          iActSetDisabled(iAct_Control_UAbility3,GameLog_ReqMsg(LocalPlayer,uid_ability3,lmt_argt_ability,unit_AbilityCheck(ui_CommandercPU,uid_ability3,false),x,y,true) );

      iActSetOnEnabled(iAct_Control_UAMove    ,(ui_uibtn_move>0)or(ui_uibtn_attack>0),true );
      iActSetOnEnabled(iAct_Control_UAStop    ,(ui_uibtn_move>0)or(ui_uibtn_attack>0),true );
      iActSetOnEnabled(iAct_Control_UAPatrol  , ui_uibtn_apatrol>0                   ,true );

      iActSetOnEnabled(iAct_Control_UMove     , ui_uibtn_move>0                      ,true );
      iActSetOnEnabled(iAct_Control_UStop     , ui_uibtn_move>0                      ,true );
      iActSetOnEnabled(iAct_Control_UPatrol   , ui_uibtn_move>0                      ,true );

      iActSetOnEnabled(iAct_Control_USelBase  , true                                 ,ui_group_f1.ugroup_n>0);
      iActSetOnEnabled(iAct_Control_USelArmy  , true                                 ,ui_group_f2.ugroup_n>0);

      iActSetOnEnabled(iAct_Control_UProdCncl , ui_uibtn_ProdCncl>0                  ,true );

      if(POVPlayer=nil)
      then iActSetOnEnabled(iAct_Control_UDestroy,false                   ,false)
      else iActSetOnEnabled(iAct_Control_UDestroy,POVPlayer^.units_all_s>0,true );
   end;

   // replay controls
   iActSetOnEnabled(iAct_Replay_Fast         ,ctabType=tcc_Replay,g_status=gs_running);
   iActSetOnEnabled(iAct_Replay_Pause        ,ctabType=tcc_Replay,replay_Pause(true));
   iActSetOnEnabled(iAct_Replay_Back2        ,ctabType=tcc_Replay,replay_SetPlayPosition(      g_tick -(fr_fps1*2 )+1,-1     ,true));
   iActSetOnEnabled(iAct_Replay_Back10       ,ctabType=tcc_Replay,replay_SetPlayPosition(      g_tick -(fr_fps1*10)+1,-1     ,true));
   iActSetOnEnabled(iAct_Replay_Back60       ,ctabType=tcc_Replay,replay_SetPlayPosition(      g_tick -(fr_fps1*60)+1,-1     ,true));
   iActSetOnEnabled(iAct_Replay_Forward2     ,ctabType=tcc_Replay,replay_SetPlayPosition(int64(g_tick)+(fr_fps1*2 )+1,fr_fps1,true));
   iActSetOnEnabled(iAct_Replay_Forward10    ,ctabType=tcc_Replay,replay_SetPlayPosition(int64(g_tick)+(fr_fps1*10)+1,fr_fps1,true));
   iActSetOnEnabled(iAct_Replay_Forward60    ,ctabType=tcc_Replay,replay_SetPlayPosition(int64(g_tick)+(fr_fps1*60)+1,fr_fps1,true));
   iActSetOnEnabled(iAct_Replay_POV          ,ctabType=tcc_Replay,true);
   iActSetOnEnabled(iAct_Replay_Log          ,ctabType=tcc_Replay,true);
   iActSetOnEnabled(iAct_Replay_Fog          ,ctabType=tcc_Replay,true);
   iActSetOnEnabled(iAct_Replay_PlayerAll    ,ctabType=tcc_Replay,true);

   for ucl:=0 to LastPlayer do
   iActSetOnEnabled(iAct_Replay_Player0+ucl  ,ctabType=tcc_Replay,ui_SetUIPlayer(ucl,true));

   // observer controls
   iActSetOnEnabled(iAct_Observer_Fog        , ctabType=tcc_Observer,true);
   iActSetOnEnabled(iAct_Observer_POV        ,(ctabType=tcc_Observer)and(net_status<>ns_none),ui_ObserverPov(UIPlayer));
   iActSetOnEnabled(iAct_Observer_PlayerAll  , ctabType=tcc_Observer,true);
   for ucl:=0 to LastPlayer do
   iActSetOnEnabled(iAct_Observer_Player0+ucl,ctabType=tcc_Observer,ui_SetUIPlayer(ucl,true));
end;

procedure MapMarker(x,y,mType:integer);
begin
   if(net_status=ns_client)
   then net_SendMapMark(x,y,mType)
   else GameLog_MapMark(LocalPlayer,x,y,mType);
   m_brush:=co_empty;
end;

procedure ui_CommandEffect(cmd,otar,ox,oy:integer;oid:byte);
function local_TarIsEnemy:boolean;
begin
   local_TarIsEnemy:=false;
   if(IsUnitRange(otar,nil))then
     if(g_units[otar].player^.team<>g_PlayersGame[LocalPlayer].team)then local_TarIsEnemy:=true;
end;
procedure local_ClickEffect(color:TMWColor);
begin
   ui_click_eff(ox,oy,fr_fpsq,color);
end;
procedure local_UnitMarkEffect;
begin
   ui_umark_u:=otar;
   ui_umark_t:=fr_fpsh;
end;
procedure local_CommandSound(default:PTSoundSet);
begin
   with ui_CommandercPU^ do
   with uid^ do
   if(uid_HaveRallypoint)then
   begin
      snd_SoundPlayUnitCommand(snd_rally_point[ui_CommandercPU^.player^.race]);
      exit;
   end
   else
     case iscomplete of
     false: if(uid_isbuilding)then
            begin
               snd_SoundPlayUnitCommand(snd_building[uid_race]);
               exit;
            end;
     true : if(transformTimer>0)then
            begin
               if(g_uids[transformUID].uid_isbuilding)
               then snd_SoundPlayUnitCommand(snd_building[uid_race])
               else snd_SoundPlayUnitCommand(uid_snd_select);
               exit;
            end;
     end;
   snd_SoundPlayUnitCommand(default);
end;

begin
   if(ui_CommandercPU<>nil)then
     with ui_CommandercPU^.uid^ do
     begin
        case cmd of
        co_move,
        co_patrol : local_CommandSound(uid_snd_move);
        co_amove,
        co_apatrol: local_CommandSound(uid_snd_attack);
        co_rcamove: if(uid_HaveRallypoint)
                    then local_CommandSound(snd_rally_point[ui_CommandercPU^.player^.race])
                    else local_CommandSound(uid_snd_attack);
        co_rcmove : if(uid_HaveRallypoint)
                    then local_CommandSound(snd_rally_point[ui_CommandercPU^.player^.race])
                    else
                      if(local_TarIsEnemy)
                      then local_CommandSound(uid_snd_attack)
                      else local_CommandSound(uid_snd_move  );
        end;

        case cmd of
        co_ability: with g_aids[oid]do
                      case ua_type of
                      uat_point    : local_ClickEffect(c_aqua);
                      uat_UnitAny,
                      uat_UnitOwn,
                      uat_UnitAlly,
                      uat_UnitEnemy: if(not IsUnitRange(otar,nil))then local_UnitMarkEffect;
                      end;
        co_move,
        co_patrol : local_ClickEffect(c_lime);
        co_apatrol: local_ClickEffect(c_red);
        co_amove,
        co_rcamove: if(not IsUnitRange(otar,nil))then local_ClickEffect(c_red ) else local_UnitMarkEffect;
        co_rcmove : if(not IsUnitRange(otar,nil))then local_ClickEffect(c_lime) else local_UnitMarkEffect;
        end;
     end;
end;

procedure PlayerSendOrder(ox0,oy0,ox1,oy1:integer;oa0,oid,playerN:byte);
var u:integer;
begin
   if(g_status=gs_running)and(rpls_pstate<rpls_read)then
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

         with g_PlayersGame[LocalPlayer] do
           net_writeint(units_all_s);
         for u:=1 to MaxUnits do
           with g_punits[u]^ do
             if(hits>0)and(isselected)and(LocalPlayer=playeri)and(not IsUnitRange(transportU,nil))then
             begin
                net_writeint (unum);
                net_writebyte(group);
             end;

         net_send(net_cl_svip,net_cl_svport);
      end
      else
        with g_PlayersTemp[playerN] do
        begin
           o_x0:=ox0;
           o_y0:=oy0;
           o_x1:=ox1;
           o_y1:=oy1;
           o_a0:=oa0;
           o_id:=oid;
        end;

      if(oid=uo_corder)then ui_CommandEffect(ox0,oy0,ox1,oy1,oid);
   end;
end;

function mouse_BrushTarget(tx,ty,mbrush:integer):integer;
var
u        : integer;
btar_pu  : PTUnit;
pUIPlayer: PTPlayerGameData;
begin
   mouse_BrushTarget:=0;

   if(not PointInCam(tx,ty))then exit;

   if(UIPlayer<=LastPlayer)
   then pUIPlayer:=@g_PlayersGame[UIPlayer]
   else pUIPlayer:=nil;

   if(pUIPlayer<>nil)then
     case mbrush of
     -255..-1: with g_aids[-mbrush] do
                 case ua_type of
                 uat_UnitAny,
                 uat_UnitOwn,
                 uat_UnitAlly,
                 uat_UnitEnemy:;
                 else exit;
                 end;
     co_empty,
     co_move,
     co_amove:; // allowed any units
     else exit;
     end;

   btar_pu:=nil;

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
          co_move,
          co_amove   :; // allowed any units
          -255..-1   : if(not ability_CheckTarget(-mbrush,pUIPlayer,player))then continue;
          end;

          if(btar_pu=nil)
          then
          else
            if(isfly>btar_pu^.isfly)
            then
            else
            if(isfly<btar_pu^.isfly)
            then exit
            else
              with uid^ do
                if(uid_r<btar_pu^.uid^.uid_r)
                then
                else
                if(uid_r>btar_pu^.uid^.uid_r)
                then exit
                else
                  if(hits<btar_pu^.hits)
                  then
                  else
                  if(hits>btar_pu^.hits)
                  then exit;

          btar_pu:=g_punits[u];
          mouse_BrushTarget:=u;
       end;
end;

procedure mouse_BrushCheck(logErrors:boolean);
var
ReqBits,
tuid   :byte;
begin
   m_brushx:=mouse_map_x;
   m_brushy:=mouse_map_y;

   case ui_ControlTabType of
   tcc_controls: case m_brush of
                 1..255             : if not(m_brush in ui_bprod_possible)then
                                      begin
                                         if(logErrors)then GameLog_ReqMsg(LocalPlayer,byte(m_brush),lmt_argt_unit,lmt_unit_NeedBuilder,-1,-1);
                                         m_brush:=co_empty;
                                      end
                                      else
                                      begin
                                         ReqBits:=CheckUnitReqs(@g_PlayersGame[LocalPlayer],m_brush);
                                         if(ReqBits>0)then
                                         begin
                                            if(logErrors)then GameLog_ReqMsg(LocalPlayer,byte(m_brush),lmt_argt_unit,ReqBits,-1,-1);
                                            m_brush:=co_empty;
                                         end
                                         else
                                           with g_PlayersGame[LocalPlayer] do
                                           begin
                                              if(not InputAction(iact_Control))then
                                              begin
                                                 BuildingFindNewPlace(mouse_map_x,mouse_map_y,m_brush,LocalPlayer,@m_brushx,@m_brushy);
                                                 m_brushx:=mm3i(ui_cam_x,m_brushx,ui_cam_x+ui_cam_w);
                                                 m_brushy:=mm3i(ui_cam_y,m_brushy,ui_cam_y+ui_cam_h);
                                              end;

                                              case CheckBuildPlace(m_brushx,m_brushy,0,0,LocalPlayer,m_brush) of
                                              cbp_good   :  m_brushc:=c_lime;
                                              cbp_noplace:  m_brushc:=c_red;
                                              cbp_out    :  m_brushc:=c_blue;
                                              else          m_brushc:=c_gray;
                                              end;
                                           end;
                                      end;
                 -254..-1           : with g_aids[-m_brush] do
                                        case ua_type of
                                        uat_point,
                                        uat_UnitAny,
                                        uat_UnitOwn,
                                        uat_UnitAlly,
                                        uat_UnitEnemy: if(ui_CommandercPU=nil)
                                                       then m_brush:=co_empty
                                                       else
                                                         with ui_CommandercPU^ do
                                                           if(GameLog_ReqMsg(LocalPlayer,byte(-m_brush),lmt_argt_ability,unit_AbilityCheck(ui_CommandercPU,byte(-m_brush),false),x,y,not logErrors))
                                                           then m_brush:=co_empty
                                                           else
                                                           begin
                                                              m_brushc:=c_aqua;
                                                              tuid:=unit_AbilityGetUIDRef(byte(-m_brush),ui_CommandercPU^.uidi);
                                                              if(tuid>0)then
                                                                with g_uids[tuid] do
                                                                begin
                                                                   if(not InputAction(iact_Control))
                                                                   then math_push_out(mouse_map_x,mouse_map_y,uid_r,unum,@m_brushx,@m_brushy,true,LocalPlayer)
                                                                   else
                                                                   begin
                                                                      m_brushx:=mouse_map_x;
                                                                      m_brushy:=mouse_map_y;
                                                                   end;

                                                                   if(CheckCollisionR(m_brushx,m_brushy,uid_r,unum,uid_isbuilding,true,g_PlayersGame[LocalPlayer].team)<>cbr_no)
                                                                   then m_brushc:=c_red;
                                                                end;
                                                           end
                                        else m_brush:=co_empty
                                        end;

                 co_move            : if(not iActEnabled(iAct_Control_UMove     ))then m_brush:=co_empty;
                 co_patrol          : if(not iActEnabled(iAct_Control_UPatrol   ))then m_brush:=co_empty;
                 co_amove           : if(not iActEnabled(iAct_Control_UAMove    ))then m_brush:=co_empty;
                 co_apatrol         : if(not iActEnabled(iAct_Control_UAPatrol  ))then m_brush:=co_empty;
                 co_markLook        : if(not iActEnabled(iAct_Control_MarkLook  ))then m_brush:=co_empty;
                 co_markAttack      : if(not iActEnabled(iAct_Control_MarkAttack))then m_brush:=co_empty;
                 else  m_brush:=co_empty
                 end;
   tcc_observer: case m_brush of
                 co_markLook        : if(not iActEnabled(iAct_Control_MarkLook  ))then m_brush:=co_empty;
                 co_markAttack      : if(not iActEnabled(iAct_Control_MarkAttack))then m_brush:=co_empty;
                 else m_brush:=co_empty;
                 end;
   else m_brush:=co_empty
   end;
end;

procedure ui_MBrush2Command(x,y,target:integer);
begin
   case m_brush of
1..255     : begin
                if(m_brushc=c_lime)
                then PlayerSendOrder(m_brushx,m_brushy,0,0,byte(m_brush),
                                                     uo_build ,LocalPlayer)
                else GameLog_ReqMsg(LocalPlayer,byte( m_brush),lmt_argt_unit   ,lmt_prod_BadPlace ,mouse_map_x,mouse_map_y);
                exit;
             end;
-255..-1   : begin
                if(m_brushc=c_aqua)
                then PlayerSendOrder(co_ability,target,x,y,byte(-m_brush),
                                                     uo_corder,LocalPlayer)   // ability
                else GameLog_ReqMsg(LocalPlayer,byte(-m_brush),lmt_argt_ability,lmt_invalid_Target,mouse_map_x,mouse_map_y);
                if(g_PlayersGame[LocalPlayer].units_all_s>1)then exit;
             end;
co_move    : PlayerSendOrder(m_brush   ,target,x,y,0,uo_corder,LocalPlayer);  // move
co_amove   : PlayerSendOrder(m_brush   ,target,x,y,0,uo_corder,LocalPlayer);  // attack
co_patrol,
co_apatrol : PlayerSendOrder(m_brush   ,0     ,x,y,0,uo_corder,LocalPlayer);
co_empty   : if(ui_uibtn_move  >0) // rclick
             or(ui_uibtn_attack>0)
             or(ui_uibtn_rpoint>0)then
        if(m_RightClickAct)
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
                                 with g_PlayersGame[LocalPlayer] do
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

   iAct_Control_UAbility1 : if(click_type=pct_left)and(ui_CommandercpU<>nil)then
                              with ui_CommandercpU^ do
                              with uid^ do
                                with g_aids[uid_ability1] do
                                  if(ua_type>uat_passive)then
                                    if(SoundOn)then
                                      if(not GameLog_ReqMsg(LocalPlayer,uid_ability1,lmt_argt_ability,unit_AbilityCheck(ui_CommandercPU,uid_ability1,false),x,y,false))then
                                        if(ua_type=uat_notarget)
                                        then PlayerSendOrder(co_ability,0,ui_cam_cx,ui_cam_cy,uid_ability1,uo_corder,LocalPlayer)
                                        else m_brush:=-uid_ability1;
   iAct_Control_UAbility2 : if(click_type=pct_left)and(ui_CommandercpU<>nil)then
                              with ui_CommandercpU^ do
                              with uid^ do
                                with g_aids[uid_ability2] do
                                  if(ua_type>uat_passive)then
                                    if(SoundOn)then
                                      if(not GameLog_ReqMsg(LocalPlayer,uid_ability2,lmt_argt_ability,unit_AbilityCheck(ui_CommandercPU,uid_ability2,false),x,y,false))then
                                        if(ua_type=uat_notarget)
                                        then PlayerSendOrder(co_ability,0,ui_cam_cx,ui_cam_cy,uid_ability2,uo_corder,LocalPlayer)
                                        else m_brush:=-uid_ability2;
   iAct_Control_UAbility3 : if(click_type=pct_left)and(ui_CommandercpU<>nil)then
                              with ui_CommandercpU^ do
                              with uid^ do
                                with g_aids[uid_ability3] do
                                  if(ua_type>uat_passive)then
                                    if(SoundOn)then
                                      if(not GameLog_ReqMsg(LocalPlayer,uid_ability3,lmt_argt_ability,unit_AbilityCheck(ui_CommandercPU,uid_ability3,false),x,y,false))then
                                        if(ua_type=uat_notarget)
                                        then PlayerSendOrder(co_ability,0,ui_cam_cx,ui_cam_cy,uid_ability3,uo_corder,LocalPlayer)
                                        else m_brush:=-uid_ability3;

   iAct_Control_UAMove    : if(SoundEnabledLeft)then m_brush :=co_amove;
   iAct_Control_UAPatrol  : if(SoundEnabledLeft)then m_brush :=co_apatrol;
   iAct_Control_UMove     : if(SoundEnabledLeft)then m_brush :=co_move;
   iAct_Control_UPatrol   : if(SoundEnabledLeft)then m_brush :=co_patrol;
   iAct_Control_UAStop    : if(SoundEnabledLeft)then PlayerSendOrder(co_astand,0,0,0,0,uo_corder,LocalPlayer);
   iAct_Control_UStop     : if(SoundEnabledLeft)then PlayerSendOrder(co_stand ,0,0,0,0,uo_corder,LocalPlayer);
   iAct_Control_UProdCncl : if(SoundEnabledLeft)then
                              with g_PlayersGame[LocalPlayer] do
                                if(ui_uibtn_ProdCncl>0)then
                                   PlayerSendOrder(co_pcancle,0,ui_cam_cx,ui_cam_cy,255,uo_corder,LocalPlayer);
   iAct_Control_UDestroy  : if(SoundEnabledLeft)then PlayerSendOrder(co_destroy,0,0,0,0,uo_corder,LocalPlayer);
   iAct_Control_MarkLook  : if(SoundEnabledLeft)then m_brush :=co_markLook;
   iAct_Control_MarkAttack: if(SoundEnabledLeft)then m_brush :=co_markAttack;

   iAct_InGamePause       : if(SoundEnabledLeft)then Game_PauseToggle(false);
   iAct_InGameMenu        : if(SoundEnabledLeft)then GameOpenMenu;

   iAct_Replay_Fast       : if(SoundEnabledLeft)then sys_uncappedFPS:=not sys_uncappedFPS;
   iAct_Replay_Pause      : if(SoundEnabledLeft)then replay_Pause(false);
   iAct_Replay_Back2      : if(SoundEnabledLeft)then replay_SetPlayPosition(      g_tick -(fr_fps1*2 )+1,-1     ,false);
   iAct_Replay_Back10     : if(SoundEnabledLeft)then replay_SetPlayPosition(      g_tick -(fr_fps1*10)+1,-1     ,false);
   iAct_Replay_Back60     : if(SoundEnabledLeft)then replay_SetPlayPosition(      g_tick -(fr_fps1*60)+1,-1     ,false);
   iAct_Replay_Forward2   : if(SoundEnabledLeft)then replay_SetPlayPosition(int64(g_tick)+(fr_fps1*2 )+1,fr_fps1,false);
   iAct_Replay_Forward10  : if(SoundEnabledLeft)then replay_SetPlayPosition(int64(g_tick)+(fr_fps1*10)+1,fr_fps1,false);
   iAct_Replay_Forward60  : if(SoundEnabledLeft)then replay_SetPlayPosition(int64(g_tick)+(fr_fps1*60)+1,fr_fps1,false);
   iAct_Replay_POV        : if(SoundEnabledLeft)then ui_playerPOV:=not ui_playerPOV;
   iAct_Replay_Log        : if(SoundEnabledLeft)then rpls_showlog:=not rpls_showlog;
   iAct_Replay_Fog        : if(SoundEnabledLeft)then ui_fog      :=not ui_fog;
   iAct_Replay_PlayerAll  : if(SoundEnabledLeft)then UIPlayer    :=255;
   iAct_Replay_Player0..
   iAct_Replay_Player7    : if(SoundEnabledLeft)then ui_SetUIPlayer(action-iAct_Replay_Player0,false);

   iAct_Observer_Fog      : if(SoundEnabledLeft)then ui_fog      :=not ui_fog;
   iAct_Observer_POV      : if(SoundEnabledLeft)then ui_playerPOV:=not ui_playerPOV;
   iAct_Observer_PlayerAll: if(SoundEnabledLeft)then UIPlayer    :=255;
   iAct_Observer_Player0..
   iAct_Observer_Player7  : if(SoundEnabledLeft)then ui_SetUIPlayer(action-iAct_Observer_Player0,false);
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
                  tab_Upgrades : ui_ExecInGameAction(ui_panel_PTabIActs[m_BtnN                  ],click_type,clickSound);
                  tab_Controls : ui_ExecInGameAction(ui_panel_CTabIActs[ui_ControlTabType,m_BtnN],click_type,clickSound);
                  end;

   else
   end;
end;

procedure WindowEvents;
var i:byte;
nvid_vw,
nvid_vh:integer;
begin
   for i:=0 to 255 do inputAction_TimerProc(i);

   if(k_LastChar_t<0)
   then k_LastChar_t:=0
   else
     if(0<k_LastChar_t)and(k_LastChar_t<k_LastChar_t.MaxValue)then k_LastChar_t+=1;

   k_KeyboardString:='';
   nvid_vw:=-1;
   nvid_vh:=-1;

   if(k_LastChar_t>k_LastCharStuckDelay)then
     if(length(k_KeyboardString)<255)then k_KeyboardString+=k_LastChar;

   while (SDL_PollEvent(sys_EVENT)>0) do
     case (sys_EVENT^.type_) of
      SDL_QUITEV         : GameCycle:=false;
      //SDL_ACTIVEEVENT    : sys_WindowFocus:=not sys_WindowFocus;
      SDL_VIDEORESIZE    : begin
                              nvid_vw:=max2i(vid_minw,sys_EVENT^.resize.w);
                              nvid_vh:=max2i(vid_minh,sys_EVENT^.resize.h);
                           end;
      SDL_MOUSEMOTION    : begin
                              if(m_DragCamMove)and(not MainMenu)and(g_started)then
                              begin
                                 ui_cam_x-=sys_EVENT^.motion.x-mouse_x;
                                 ui_cam_y-=sys_EVENT^.motion.y-mouse_y;
                                 ui_Camera_Bounds;
                              end;
                              mouse_prev_x:=mouse_x;
                              mouse_prev_y:=mouse_y;
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

   if (nvid_vw>0)
   and(nvid_vh>0)then
   begin
      vid_vw:=nvid_vw;menu_ResolutionWi:=vid_vw;
      vid_vh:=nvid_vh;menu_ResolutionHi:=vid_vh;

      vid_MakeScreen;
      theme_map_pTerrain:=255;
      gfx_MapMakeTerrain;
      menu_update:=true;
   end;
end;

procedure GameControlsMouse;
var
   u,bx,by:integer;
clickSound:PTSoundSet;
begin
   clickSound:=nil;

   // panel btn focus
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

   // mouse focus
   m_uifocus:=mf_map;
   if (0<=bx)and(bx<ui_CtrlPanelBW)
   and(0<=by)and(by<=ui_CtrlPanelBL)then
     if(by<ui_CtrlPanelBW)
     then m_uifocus:=mf_MiniMap
     else
       if(by=ui_CtrlPanelBW)
       then m_uifocus:=mf_Tabs
       else
         if(by=ui_CtrlPanelBL)
         then m_uifocus:=mf_MenuPause
         else m_uifocus:=mf_CtrlPanel;
   case m_uifocus of
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
   // map mouse
   if(m_uifocus=mf_MiniMap)then
   begin
      mouse_map_x:=round((mouse_x-ui_UIPanelX)/map_MiniMap_cx);
      mouse_map_y:=round((mouse_y-ui_UIPanelY)/map_MiniMap_cx);
   end
   else
   begin
      mouse_map_x:=mouse_x+ui_cam_x;
      mouse_map_y:=mouse_y+ui_cam_y;
   end;

   mouse_BrushCheck(false);

   m_UnitTargetN:=0;
   m_UnitTargetP:=nil;
   if(m_uifocus=mf_Map)then
     if(mouse_select_xs0=NOTSET)
     or(CheckPointClick(mouse_select_xs0,mouse_select_ys0,mouse_map_x,mouse_map_y))then
     begin
        m_UnitTargetN:=mouse_BrushTarget(mouse_map_x,mouse_map_y,m_brush);
        if(m_UnitTargetN>0)then
          m_UnitTargetP:=g_punits[m_UnitTargetN];
     end;

   if(InputActionPressed(iact_MLB))then                // LMB down
     case m_uifocus of
     mf_map      : case m_brush of
                   co_empty     : if(m_UnitTargetP<>nil)and( InputAction(iact_Control)or InputActionDPressed(iact_MLB) )then
                                  begin
                                     if(m_UnitTargetP^.playeri=UIPlayer)then
                                       units_SelectRect(InputAction(iact_Shift),ui_cam_x,ui_cam_y, ui_cam_x+ui_cam_w,ui_cam_y+ui_cam_h,m_UnitTargetP^.uidi);
                                  end
                                  else
                                  begin
                                     if(m_UnitTargetP<>nil)then
                                       if(ui_UpdateUIPlayer(m_UnitTargetN))then exit;
                                     mouse_select_xs0:=mouse_map_x;
                                     mouse_select_ys0:=mouse_map_y;
                                  end;
                   1..255,
                   -255..-1,
                   co_move,
                   co_amove,
                   co_patrol,
                   co_apatrol   : ui_MBrush2Command(m_brushx,m_brushy,m_UnitTargetN);
                   co_markLook  : MapMarker(mouse_map_x,mouse_map_y,m_brush);
                   co_markAttack: MapMarker(mouse_map_x,mouse_map_y,m_brush);
                   end;
     mf_minimap  : case m_brush of
                   -255..-1,
                   co_move,
                   co_amove,
                   co_patrol,
                   co_apatrol   : ui_MBrush2Command(m_brushx,m_brushy,m_UnitTargetN);
                   co_markLook  : MapMarker(mouse_map_x,mouse_map_y,m_brush);
                   co_markAttack: MapMarker(mouse_map_x,mouse_map_y,m_brush);
                   else           if(not ui_playerPOV)then m_mmap_move:=true;
                   end;
     mf_tabs     : if(0<=m_btnN)and(m_btnN<4)then
                   begin
                      u:=ui_tab;
                      ui_tab:=byte(m_btnN);
                      clickSound:=snd_click;
                      if(u<>ui_tab)then ui_EnableControlActs;
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
         if(m_UnitTargetP<>nil)
         then units_SelectRect(InputAction(iact_Shift),mouse_select_xs0,mouse_select_ys0,mouse_map_x,mouse_map_y,-m_UnitTargetP^.unum)
         else units_SelectRect(InputAction(iact_Shift),mouse_select_xs0,mouse_select_ys0,mouse_map_x,mouse_map_y,0);

         mouse_select_xs0:=NOTSET;
      end;
   end;

   if(m_mmap_move)and(mouse_select_xs0=NOTSET)then
   begin
      ui_Camera_MoveToPoint(trunc((mouse_x-ui_UIPanelX)/map_MiniMap_cx), trunc((mouse_y-ui_UIPanelY)/map_MiniMap_cx));
      ui_Camera_Bounds;
   end;

 //  if(k_mr=2)then effect_add(mouse_map_x,mouse_map_y-50,10000,UID_PainC);
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
       case m_uifocus of
       mf_map,
       mf_minimap  : ui_MBrush2Command(mouse_map_x,mouse_map_y,m_UnitTargetN);
       mf_CtrlPanel: ui_ControlPanel_click(pct_right,@clickSound);     // panel
       end;

   if(InputActionPressed(iact_MMB))then            // MMB down
     case m_uifocus of
     mf_map      : m_DragCamMove:=true;
     mf_minimap  : ;
     mf_CtrlPanel: ;
     end;

   if(InputActionReleased(iact_MMB))then           // MMB up
     m_DragCamMove:=false;

   if(clickSound<>nil)then snd_SoundPlayUI(clickSound);
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

procedure GameControlsKeyboard;
var
ctab :TTabControlContent;
act,k:byte;
clickSound:boolean;
begin
   clickSound:=false;
   if(not m_DragCamMove)and(not ui_playerPOV)then GameControlsCameraMove;

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
              if(ui_InGameChat>0)then
                if(net_status=ns_client)
                then net_send_chat(            ui_InGameChat,net_chat_str)
                else GameLog_Chat (LocalPlayer,ui_InGameChat,net_chat_str);
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

   // Escape (cancel chat)
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
      {$IFDEF TESTMODE}
      // Test mode
      if(TestMode>0)and(net_status=ns_none){and(rpls_pstate<>rpls_read)}then
      begin
         if(InputActionPressed(iAct_test_FastTime    ))then sys_uncappedFPS:=not sys_uncappedFPS;
         if(InputActionPressed(iAct_test_InstaProd   ))then test_InstaProd :=not test_InstaProd;
         if(InputActionPressed(iAct_test_ToggleAI    ))then with g_PlayersGame[LocalPlayer] do if(state=ps_human          )then state:=ps_AI              else state:=ps_human;
         if(InputActionPressed(iAct_test_iddqd       ))then with g_PlayersGame[LocalPlayer] do if(upgrs_cur[upgr_invuln]=0)then upgrs_cur[upgr_invuln]:=1 else upgrs_cur[upgr_invuln]:=0;
         if(InputActionPressed(iAct_test_FogToggle   ))then ui_fog  :=not ui_fog;
         if(InputActionPressed(iAct_test_DrawToggle  ))then vid_draw:=not vid_draw;
         if(InputActionPressed(iAct_test_NullUpgrades))then with g_PlayersGame[LocalPlayer] do FillChar(upgrs_cur,SizeOf(upgrs_cur),0);
         if(InputActionPressed(iAct_test_BePlayer0   ))then LocalPlayer:=0;
         if(InputActionPressed(iAct_test_BePlayer1   ))then LocalPlayer:=1;
         if(InputActionPressed(iAct_test_BePlayer2   ))then LocalPlayer:=2;
         if(InputActionPressed(iAct_test_BePlayer3   ))then LocalPlayer:=3;
         if(InputActionPressed(iAct_test_BePlayer4   ))then LocalPlayer:=4;
         if(InputActionPressed(iAct_test_BePlayer5   ))then LocalPlayer:=5;
         if(InputActionPressed(iAct_test_BePlayer6   ))then LocalPlayer:=6;
         if(InputActionPressed(iAct_test_BePlayer7   ))then LocalPlayer:=7;
         if(InputActionPressed(iAct_test_AddHellPower))then with g_PlayersGame[LocalPlayer] do res_HellPower:=min2i(res_HellPower+testmode_HellPower,HellPower_Max);
         if(InputActionPressed(iAct_test_AddUACLoot  ))then with g_PlayersGame[LocalPlayer] do res_UACLoot  :=min2i(res_UACLoot  +testmode_UACLoot  ,UACLoot_Max  );

        // if(InputActionPressed(iAct_test_debug0      ))then net_debug:= not net_debug;
         if(InputActionPressed(iAct_test_debug1      ))then TestMode:=0;
      end;
      {$ENDIF}

      // To last event
      if(InputActionPressed(iAct_LastEvent))then
      begin
         ui_Camera_ToLastEvent;
         clickSound:=true;
      end;

      // Controls tab actions
      ctab:=ui_ControlTabType;
      if(ctab=tcc_observer)
      or(ctab=tcc_replay  )
      or(g_status=gs_running)then
        for k:=0 to ui_ButtonsNum do
        begin
           act:=ui_panel_CTabIActs[ctab,k];
           if(InputActionPressed(act))then
             ui_ExecInGameAction(act,pct_left,@clickSound);
        end;

      // Record toggle
      if(ctab=tcc_controls)then
        if(InputActionPressed(iAct_Control_ToggleRec))then menu_ToggleRecord;

      if(g_status=gs_running)then
      begin
         // Groups
         for k:=iAct_USetGroup0 to iAct_USetGroup9 do if(InputActionPressed(k))then units_SetGroup   (false,k-iAct_USetGroup0);
         for k:=iAct_UAddGroup1 to iAct_UAddGroup9 do if(InputActionPressed(k))then units_SetGroup   (true ,k-iAct_UAddGroup1+1);
         for k:=iAct_UASlGroup1 to iAct_UASlGroup9 do if(InputActionPressed(k))then units_SelectGroup(true ,k-iAct_UASlGroup1+1);
         for k:=iAct_USelGroup1 to iAct_USelGroup9 do
           if(InputActionDPressed(k))
           then ui_Camera_MoveToGroup(@ui_group_d[k-iAct_USelGroup1+1])
           else
             if(InputActionPressed(k))
             then units_SelectGroup(false,k-iAct_USelGroup1+1);

         // unit common controls
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

   if(clickSound)then snd_SoundPlayUI(snd_click);
end;


procedure GameInput;
begin
   WindowEvents;

   if(InputActionReleased(iact_Screenshot))then gfx_MakeScreenshot;
   if(InputActionPressed(iAct_ToggleWindowed))then menu_ToggleFullScreen;

   if(MainMenu)then
   begin
      menu_Controls;
   end
   else
   begin
      GameControlsKeyboard;
      GameControlsMouse;
      unit_UICountersAll;
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
         mi_Map_Seed        : menu_mseed        :=c2s(map_seed);
         mi_SV_ResolutionW  : menu_ResolutionWi :=vid_vw;
         mi_SV_ResolutionH  : menu_ResolutionHi :=vid_vh;
         mi_MP_ServerPort   : menu_ServerPort   :=w2s(net_ServerPort);
         mi_MP_ClientAddress: menu_ClientAddress:=c2ip(net_cl_svip)+':'+w2s(swap(net_cl_svport));
         end;
         menu_ItemSelected:=0;
      end;
   end;
end;



