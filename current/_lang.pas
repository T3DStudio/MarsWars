
function l2s(limit,base:longint):shortstring; // limit 2 string
var fr:integer;
begin
   fr:=limit mod base;
   case fr of
   0  : l2s:=i2s(limit div base);
   50 : l2s:=i2s(limit div base)+'.5';
   25 : l2s:=i2s(limit div base)+'.25';
   75 : l2s:=i2s(limit div base)+'.75';
   else l2s:=i2s(limit div base)+'.'+i2s(fr);
   end;
end;

function GetKeyName(k:cardinal):shortstring;
begin
   case k of
SDL_BUTTON_left     : GetKeyName:='Mouse left button';
SDL_BUTTON_right    : GetKeyName:='Mouse right button';
SDL_BUTTON_middle   : GetKeyName:='Mouse middle button';
SDL_BUTTON_WHEELUP  : GetKeyName:='Mouse wheel up';
SDL_BUTTON_WHEELDOWN: GetKeyName:='Mouse wheel down';
SDLK_LCtrl,
SDLK_RCtrl          : GetKeyName:='Ctrl';
SDLK_LAlt,
SDLK_RAlt           : GetKeyName:='Alt';
SDLK_LShift,
SDLK_RShift         : GetKeyName:='Shift';
   else GetKeyName  :=UpperCase(SDL_GetKeyName(k));
   end
end;



function _gHK(ucl:byte):shortstring;  // hotkey units&upgrades tab
begin
   _gHK:='';
   if(ucl<=_mhkeys)then
    if(_hotkey1[ucl]>0)then
    begin
       if(_hotkey2[ucl]>0)then
       _gHK:=     tc_lime+GetKeyName(_hotkey2[ucl])+tc_default+'+';
       _gHK:=_gHK+tc_lime+GetKeyName(_hotkey1[ucl])+tc_default;
    end;
end;
function _gHKA(ucl:byte):shortstring;  // hotkey actions tab
begin
   _gHKA:='';
   if(ucl<=_mhkeys)then
    if(_hotkeyA[ucl]>0)then
    begin
       if(_hotkeyA2[ucl]>0)then
       _gHKA:=      tc_lime+GetKeyName(_hotkeyA2[ucl])+tc_default+'+';
       _gHKA:=_gHKA+tc_lime+GetKeyName(_hotkeyA [ucl])+tc_default;
    end;
end;
function _gHKR(ucl:byte):shortstring;  // hotkey replays tab
begin
   _gHKR:='';
   if(ucl<=_mhkeys)then
    if(_hotkeyR[ucl]>0)then
     _gHKR:=tc_lime+GetKeyName(_hotkeyR [ucl])+tc_default;
end;
function _gHKO(ucl:byte):shortstring;  // hotkey observer tab
begin
   _gHKO:='';
   if(ucl<=_mhkeys)then
    if(_hotkeyR[ucl]>0)then
     _gHKO:=tc_lime+GetKeyName(_hotkeyO [ucl])+tc_default;
end;


procedure _mkHStrACT(ucl:byte;hint:shortstring);
var hk:shortstring;
begin
   if(ucl<=_mhkeys)then
   begin
      hk:=_gHKA(ucl);
      if(length(hk)>0)
      then str_hint_a[ucl]:=hint+' ('+hk+')'
      else str_hint_a[ucl]:=hint;
   end;
end;

procedure _mkHStrRPL(ucl:byte;hint:shortstring;noHK:boolean);
var hk:shortstring;
begin
   if(ucl<=_mhkeys)then
   begin
      if(noHK)
      then hk:=''
      else hk:=_gHKR(ucl);
      if(length(hk)>0)
      then str_hint_r[ucl]:=hint+' ('+hk+')'
      else str_hint_r[ucl]:=hint;
   end;
end;
procedure _mkHStrOBS(ucl:byte;hint:shortstring;noHK:boolean);
var hk:shortstring;
begin
   if(ucl<=_mhkeys)then
   begin
      if(noHK)
      then hk:=''
      else hk:=_gHKO(ucl);
      if(length(hk)>0)
      then str_hint_o[ucl]:=hint+' ('+hk+')'
      else str_hint_o[ucl]:=hint;
   end;
end;
procedure _mkHStrUid(uid:byte;NAME,DESCR:shortstring);
begin
   with _uids[uid] do
   begin
      un_txt_name  :=NAME;
      un_txt_udescr:=DESCR;
   end;
end;

procedure _mkHStrUpid(upid:byte;NAME,DESCR:shortstring);
begin
   with _upids[upid] do
   begin
      _up_name :=NAME;
      _up_descr:=DESCR;
   end;
end;

procedure _ADDSTR(s:pshortstring;ad,sep:shortstring);
begin
   if(length(ad)>0)then
     if(length(s^)=0)
     then s^:=ad
     else s^:=s^+sep+ad;
end;

function findprd(uid:byte):shortstring;
var i:byte;
   up,
   bp: shortstring;
begin
   up:='';
   bp:='';
   findprd:='';
   for i:=0 to 255 do
   begin
      if(uid in _uids[i].ups_units  )then _ADDSTR(@up,_uids[i].un_txt_name,sep_comma);
      if(uid in _uids[i].ups_builder)then _ADDSTR(@bp,_uids[i].un_txt_name,sep_comma);
   end;

   if(length(up)>0)then _ADDSTR(@findprd,up,sep_comma);
   if(length(bp)>0)then _ADDSTR(@findprd,bp,sep_comma);
end;


{function _AttackHint(uid:byte):shortstring;
var mdtargets,
    ldtargets:shortstring;
begin
   _AttackHint:='';
   mdtargets  :='';
   ldtargets  :='';
   case uid of
UID_Sergant,
UID_SSergant,
UID_Imp            : begin
                     _ADDSTR(@mdtargets,str_attr_unit    ,sep_comma);
                     _ADDSTR(@mdtargets,str_attr_bio     ,sep_comma);
                     _ADDSTR(@mdtargets,str_attr_heavy   ,sep_comma);
                     end;
UID_Demon          : _ADDSTR(@mdtargets,str_attr_heavy   ,sep_comma);
UID_UCommandCenter,
UID_FPlasmagunner,
UID_UACDron,
UID_Arachnotron,
UID_Cacodemon      : begin
                     _ADDSTR(@mdtargets,str_attr_unit    ,sep_comma);
                     _ADDSTR(@mdtargets,str_attr_mech    ,sep_comma);
                     end;
UID_Commando,
UID_ZCommando,
UID_ZFormer,
UID_Engineer,
UID_Medic          : begin
                     _ADDSTR(@mdtargets,str_attr_unit    ,sep_comma);
                     _ADDSTR(@mdtargets,str_attr_bio     ,sep_comma);
                     _ADDSTR(@mdtargets,str_attr_light   ,sep_comma);
                     end;

UID_Mastermind,
UID_Baron,
UID_Knight         : begin
                     _ADDSTR(@mdtargets,str_attr_unit    ,sep_comma);
                     _ADDSTR(@mdtargets,str_attr_light   ,sep_comma);
                     end;

UID_URMStation,
UID_Cyberdemon,
UID_Mancubus,
UID_SiegeMarine,
UID_Tank,
UID_ZEngineer,
UID_ZSiegeMarine   : _ADDSTR(@mdtargets,str_attr_building,sep_comma);
   end;
   case uid of
UID_Phantom,
UID_LostSoul       : _ADDSTR(@ldtargets,str_attr_mech    ,sep_comma);
UID_URMStation,
UID_ZEngineer,
UID_Cyberdemon     : _ADDSTR(@ldtargets,str_attr_light   ,sep_comma);
UID_SSergant       : _ADDSTR(@mdtargets,str_attr_mech    ,sep_comma);
   end;
end;    }

function _makeAttributeStr(pu:PTUnit;auid:byte):shortstring;
begin
   if(pu=nil)then
   begin
      pu:=@_units[0];
      with pu^ do
      begin
         uidi:=auid;
         playeri:=0;
         player :=@_players[playeri];
      end;
      _unit_apUID(pu);
   end;
   _makeAttributeStr:='';
   with pu^  do
   with uid^ do
   begin
      if(uidi in T2)
      then _ADDSTR(@_makeAttributeStr,'T2',sep_comma)
      else
      if(uidi in T3)
      then _ADDSTR(@_makeAttributeStr,'T3',sep_comma)
      else _ADDSTR(@_makeAttributeStr,'T1',sep_comma);

      if(_ukbuilding)
      then _ADDSTR(@_makeAttributeStr,str_attr_building,sep_comma)
      else _ADDSTR(@_makeAttributeStr,str_attr_unit    ,sep_comma);
      if(_ukmech)
      then _ADDSTR(@_makeAttributeStr,str_attr_mech    ,sep_comma)
      else _ADDSTR(@_makeAttributeStr,str_attr_bio     ,sep_comma);
      if(_uklight)
      then _ADDSTR(@_makeAttributeStr,str_attr_light   ,sep_comma)
      else _ADDSTR(@_makeAttributeStr,str_attr_heavy  ,sep_comma);
      if(ukfly)
      then _ADDSTR(@_makeAttributeStr,str_attr_fly     ,sep_comma)
      else
        if(ukfloater)
        then _ADDSTR(@_makeAttributeStr,str_attr_floater,sep_comma)
        else _ADDSTR(@_makeAttributeStr,str_attr_ground ,sep_comma);
      if(apcm>0)
      then _ADDSTR(@_makeAttributeStr,str_attr_transport,sep_comma);
      if(level>0)
      then _ADDSTR(@_makeAttributeStr,str_attr_level+b2s(level+1),sep_comma);
      if(buff[ub_Detect]>0)or(_detector)
      then _ADDSTR(@_makeAttributeStr,str_attr_detector,sep_comma);
      if(buff[ub_Invuln]>0)
      then _ADDSTR(@_makeAttributeStr,str_attr_invuln,sep_comma)
      else
        if(buff[ub_Pain]>0)
        then _ADDSTR(@_makeAttributeStr,str_attr_stuned,sep_comma);

      _makeAttributeStr:='['+_makeAttributeStr+']';
   end;
end;

function BaseFlags2Str(flags:cardinal):shortstring;
function CheckFlags(f1,f2:cardinal;s1,s2:pshortstring;addifboth:boolean):boolean;
begin
   CheckFlags:=((flags and f1)>0)and((flags and f2)>0);
   if(addifboth)
   or( ((flags and f1)>0)<>((flags and f2)>0) )then
   begin
      if((flags and f1)>0)then _ADDSTR(@BaseFlags2Str,s1^,sep_comma);
      if((flags and f2)>0)then _ADDSTR(@BaseFlags2Str,s2^,sep_comma);
   end;
end;
begin
   BaseFlags2Str:='';

   CheckFlags(wtr_unit  ,wtr_building,@str_attr_unit  ,@str_attr_building,false);
   CheckFlags(wtr_bio   ,wtr_mech    ,@str_attr_bio   ,@str_attr_mech    ,false);
   CheckFlags(wtr_light ,wtr_heavy   ,@str_attr_light ,@str_attr_heavy   ,false);
   CheckFlags(wtr_ground,wtr_fly     ,@str_attr_ground,@str_attr_fly     ,false);

   if(length(BaseFlags2Str)=0)then
   CheckFlags(wtr_ground,wtr_fly     ,@str_attr_ground,@str_attr_fly     ,true );

   if(length(BaseFlags2Str)>0)then BaseFlags2Str:='['+BaseFlags2Str+']';
end;


function DamageStr(dmods:TSoB):shortstring;
var w,i:byte;
begin
   DamageStr:='';
   for w:=1 to 255 do
    if(w in dmods)then
     for i:=0 to MaxDamageModFactors do
      with _dmods[w][i] do
       if(dm_factor<>100)and(dm_flags>0)then
       begin
          _ADDSTR(@DamageStr,'x'+l2s(dm_factor,100)+' '+BaseFlags2Str(dm_flags),sep_comma);
       end;
   if(length(DamageStr)>0)then DamageStr:=str_damage+DamageStr;
end;

function _req2s(basename:shortstring;reqn:byte):shortstring;
begin
   _req2s:=basename;
   if(reqn>1)then _req2s+='(x'+b2s(reqn)+')';
end;

function _MakeDefaultDescription(uid:byte;basedesc:shortstring):shortstring;
{type
TW = record
   atflags:cardinal;
   dmods  :byte;
end;}
var w:byte;
atflags : cardinal;
dmods   : TSoB;
{   TW:array[0..MaxUnitWeapons] of TW;
procedure AddWeapon();
begin

end;}
function AddReq(ruid,rupid,rupidl:byte):shortstring;
begin
  AddReq:='';
  if(ruid >0)then _ADDSTR(@AddReq,'"'+_req2s(_uids [ruid ].un_txt_name,1     )+'"' ,sep_comma);
  if(rupid>0)then _ADDSTR(@AddReq,'"'+_req2s(_upids[rupid]._up_name   ,rupidl)+'"' ,sep_comma);
  if(length(AddReq)>0)then AddReq:='{'+tc_yellow+str_req+tc_default+AddReq+'}';
end;
function RebuildStr(uid,uidl:byte):shortstring;
begin
  if(uidl=0)
  then RebuildStr:='"'+_uids[uid].un_txt_name+'"'
  else RebuildStr:='"'+_uids[uid].un_txt_name+'['+str_attr_level+b2s(uidl+1)+']"';
end;
begin
   _MakeDefaultDescription:=basedesc;
    with _uids[uid] do
    begin
       if(_isbuilder    )then _ADDSTR(@_MakeDefaultDescription,str_builder,sep_sdot);
       if(_isbarrack    )then _ADDSTR(@_MakeDefaultDescription,str_barrack,sep_sdot);
       if(_issmith      )then _ADDSTR(@_MakeDefaultDescription,str_smith  ,sep_sdot);
       if(_genergy    >0)then _ADDSTR(@_MakeDefaultDescription,str_IncEnergyLevel+'('+tc_aqua+'+'+i2s(_genergy)+tc_default+')',sep_sdot);
       if(_rebuild_uid>0)and(_ability<>uab_RebuildInPoint)then
       begin
          _ADDSTR(@_MakeDefaultDescription,
          str_CanRebuildTo+
          RebuildStr(_rebuild_uid,_rebuild_level)+
          AddReq(_rebuild_ruid,_rebuild_rupgr,_rebuild_rupgrl),sep_sdot );
       end;
       if(_ability>0)then
        if(_ability=uab_RebuildInPoint)and(_rebuild_uid>0)
        then _ADDSTR(@_MakeDefaultDescription,str_ability+str_transformation+RebuildStr(_rebuild_uid,_rebuild_level)+AddReq(_rebuild_ruid,_rebuild_rupgr,_rebuild_rupgrl),sep_sdot)
        else
          if(length(str_ability_name[_ability])>0)
          then _ADDSTR(@_MakeDefaultDescription,str_ability+'"'+str_ability_name[_ability]+'"'+AddReq(_ability_ruid,_ability_rupgr,_ability_rupgrl),sep_sdot);

       if(_attack=atm_always)then
       begin
          atflags:=0;
          dmods  :=[];
          for w:=0 to MaxUnitWeapons do
           with _a_weap[w] do
            case aw_type of
            wpt_missle,
            wpt_directdmg,
            wpt_directdmgz : //AddWeapon(aw_tarf,aw_dmod,);
                             begin
                                atflags:=atflags or aw_tarf;
                                if(aw_dmod>0)then dmods+=[aw_dmod];
                             end;
            end;
          if(atflags>0)then
           if((atflags and wtr_fly   )>0)
           or((atflags and wtr_ground)>0)then
           begin
              _ADDSTR(@_MakeDefaultDescription,str_canattack+BaseFlags2Str(atflags),sep_sdot);
              _ADDSTR(@_MakeDefaultDescription,DamageStr(dmods),sep_sdot);
           end;
       end;

       if(length(_MakeDefaultDescription)>0)then _MakeDefaultDescription+='.';
    end;
end;

function _makeUpgrBaseHint(upid,curlvl:byte):shortstring;
var HK,
    ENRG,
    TIME,
    INFO:shortstring;
begin
  with _upids[upid] do
  begin
     HK  :=_gHK(_up_btni);
     ENRG:='';
     TIME:='';
     INFO:='';

     if(curlvl>_up_max)then curlvl:=_up_max;

     HK:=_gHK(_up_btni);
     if(_up_renerg>0)then
       if(_up_max>1)and(not _up_mfrg)
       then ENRG:=tc_aqua+i2s(_upid_energy(upid,curlvl))+tc_default
       else ENRG:=tc_aqua+i2s(_upid_energy(upid,1     ))+tc_default;
     if(_up_time  >0)then
       if(_up_max>1)and(not _up_mfrg)
       then TIME:=tc_white+i2s(_upid_time(upid,curlvl) div fr_fps1)+tc_default
       else TIME:=tc_white+i2s(_upid_time(upid,1     ) div fr_fps1)+tc_default;

     if(length(HK  )>0)then _ADDSTR(@INFO,HK  ,sep_comma);
     if(length(ENRG)>0)then _ADDSTR(@INFO,ENRG,sep_comma);
     if(length(TIME)>0)then _ADDSTR(@INFO,TIME,sep_comma);
     _ADDSTR(@INFO,tc_orange+'x'+i2s(_up_max)+tc_default,sep_comma);
     if(_up_max>1)and(_up_mfrg)then _ADDSTR(@INFO,tc_red+'*'+tc_default,sep_comma);

     _makeUpgrBaseHint:=_up_name+' ('+INFO+')'+tc_nl1+_up_descr;
  end;
end;

procedure _makeHints;
var
uid         :byte;
ENRG,HK,PROD,LMT,INFO,
TIME,REQ    :shortstring;
begin
   // units
   for uid:=0 to 255 do
   with _uids[uid] do
   begin
      REQ :='';
      PROD:='';
      ENRG:='';
      TIME:='';
      LMT :='';
      INFO:='';

      if(_ucl>=23)then
      begin
         un_txt_uihint1:=un_txt_name+tc_nl1+un_txt_fdescr+tc_nl1;
         un_txt_uihint2:='';
         un_txt_uihintS:='';
      end
      else
      begin
         HK:=_gHK(_ucl);
         if(_renergy>0)then ENRG:=tc_aqua +i2s(_renergy)+tc_default;
         if(_btime  >0)then TIME:=tc_white+i2s(_btime  )+tc_default;
         LMT:=tc_orange+l2s(_limituse,MinUnitLimit)+tc_default;

         PROD:=findprd(uid);
         if(_ruid1>0)then _ADDSTR(@REQ,_req2s(_uids [_ruid1].un_txt_name,_ruid1n),sep_comma);
         if(_ruid2>0)then _ADDSTR(@REQ,_req2s(_uids [_ruid2].un_txt_name,_ruid2n),sep_comma);
         if(_ruid3>0)then _ADDSTR(@REQ,_req2s(_uids [_ruid3].un_txt_name,_ruid3n),sep_comma);
         if(_rupgr>0)then _ADDSTR(@REQ,_req2s(_upids[_rupgr]._up_name   ,_rupgrl),sep_comma);

         if(length(HK  )>0)then _ADDSTR(@INFO,HK  ,sep_comma);
         if(length(ENRG)>0)then _ADDSTR(@INFO,ENRG,sep_comma);
         if(length(LMT )>0)then _ADDSTR(@INFO,LMT ,sep_comma);
         if(length(TIME)>0)then _ADDSTR(@INFO,TIME,sep_comma);

         un_txt_fdescr:=_MakeDefaultDescription(uid,un_txt_udescr);

         un_txt_uihint1:=un_txt_name+' ('+INFO+')'+tc_nl1+_makeAttributeStr(nil,uid);
         un_txt_uihintS:=un_txt_name+tc_nl1;
         un_txt_uihint2:=un_txt_fdescr;
         un_txt_uihint3:='';

         if(length(REQ )>0)then un_txt_uihint3+=tc_yellow+str_req+tc_default+REQ+tc_nl1
                           else un_txt_uihint3+=tc_nl1;
         if(length(PROD)>0)then
          if(_ukbuilding)
          then un_txt_uihint3+=str_bprod+PROD
          else un_txt_uihint3+=str_uprod+PROD;
      end;
   end;

   // upgrades
   for uid:=0 to 255 do
   with _upids[uid] do
   begin
      REQ  :='';

      if(_up_ruid  >0)then _ADDSTR(@REQ,_uids [_up_ruid ].un_txt_name,sep_comma);
      if(_up_rupgr >0)then _ADDSTR(@REQ,_upids[_up_rupgr]._up_name   ,sep_comma);

      _up_hint:='';
      if(length(REQ)>0)then _up_hint+=tc_yellow+str_req+tc_default+REQ;
   end;
end;

procedure lng_eng;
var t: shortstring;
begin
   str_MMap              := 'MAP';
   str_MPlayers          := 'PLAYERS';
   str_MObjectives       := 'OBJECTIVES';
   str_menu_s1[ms1_sett] := 'SETTINGS';
   str_menu_s1[ms1_svld] := 'SAVE/LOAD';
   str_menu_s1[ms1_reps] := 'REPLAYS';
   str_menu_s2[ms2_camp] := 'CAMPAIGNS';
   str_menu_s2[ms2_scir] := 'SKIRMISH';
   str_menu_s2[ms2_mult] := 'MULTIPLAYER';
   str_menu_s3[ms3_game] := 'GAME';
   str_menu_s3[ms3_vido] := 'VIDEO';
   str_menu_s3[ms3_sond] := 'SOUND';
   str_reset[false]      := 'START';
   str_reset[true ]      := 'RESET';
   str_exit[false]       := 'EXIT';
   str_exit[true]        := 'BACK';
   str_m_liq             := 'Lakes: ';
   str_m_siz             := 'Size: ';
   str_m_obs             := 'Obstacles: ';
   str_m_sym             := 'Symmetric: ';
   str_map               := 'Map';
   str_players           := 'Players';
   str_mrandom           := 'Random map';
   str_musicvol          := 'Music volume';
   str_soundvol          := 'Sound volume';
   str_scrollspd         := 'Scroll speed';
   str_mousescrl         := 'Mouse scroll';
   str_fullscreen        := 'Windowed:';
   str_plname            := 'Player name';
   str_lng[true]         := 'RUS';
   str_lng[false]        := 'ENG';
   str_maction           := 'Right click action';
   str_maction2[true ]   := tc_lime  +'move'  +tc_default;
   str_maction2[false]   := tc_lime  +'move'  +tc_default+'+'+tc_red+'attack'+tc_default;
   str_race[r_random]    := tc_white +'RANDOM'+tc_default;
   str_race[r_hell  ]    := tc_orange+'HELL'  +tc_default;
   str_race[r_uac   ]    := tc_lime  +'UAC'   +tc_default;
   str_observer          := 'OBSERV.';
   str_win               := 'VICTORY!';
   str_lose              := 'DEFEAT!';
   str_gsunknown         := 'Unknown status!';
   str_pause             := 'Pause';
   str_gsaved            := 'Game saved';
   str_repend            := 'Replay ended!';
   str_save              := 'Save';
   str_load              := 'Load';
   str_delete            := 'Delete';
   str_svld_errors_file  := 'File not'+tc_nl3+'exists!';
   str_svld_errors_open  := 'Can`t open'+tc_nl3+'file!';
   str_svld_errors_wdata := 'Wrong file'+tc_nl3+'size!';
   str_svld_errors_wver  := 'Wrong version!';
   str_time              := 'Time: ';
   str_menu              := 'Menu';
   str_player_def        := ' was terminated!';
   str_inv_time          := 'Wave #';
   str_inv_ml            := 'Monsters limit: ';
   str_play              := 'Play';
   str_replay            := 'RECORD';
   str_replay_name       := 'Replay name:';
   str_cmpdif            := 'Difficulty: ';
   str_waitsv            := 'Awaiting server...';
   str_goptions          := 'GAME OPTIONS';
   str_server            := 'SERVER';
   str_client            := 'CLIENT';
   str_menu_chat         := 'CHAT(ALL PLAYERS)';
   str_chat_all          := 'ALL:';
   str_chat_allies       := 'ALLIES:';
   str_randoms           := 'Random skirmish';
   str_apply             := 'apply';
   str_plout             := ' left the game';
   str_aislots           := 'Fill empty slots:';
   str_resol             := 'Resolution';
   str_language          := 'UI language';
   str_req               := 'Requirements: ';
   str_orders            := 'Unit groups: ';
   str_all               := 'All';
   str_uprod             := tc_lime+'Produced by: '   +tc_default;
   str_bprod             := tc_lime+'Constructed by: '+tc_default;
   str_ColoredShadow     := 'Colored shadows';
   str_kothtime          := 'Center capture time left: ';
   str_kothwinner        := ' is King of the Hill!';
   str_DeadObservers     := 'Observer mode after lose:';
   str_FPS               := 'Show FPS';
   str_APM               := 'Show APM';
   str_ability           := 'Ability: ';
   str_transformation    := 'transformation to ';
   str_upgradeslvl       := 'Upgrades: ';

   str_builder           := 'Builder';
   str_barrack           := 'Unit production';
   str_smith             := 'Researches and upgrades facility';
   str_IncEnergyLevel    := 'Increase energy level';
   str_CanRebuildTo      := 'Can be rebuilded to ';
   str_canattack         := 'Can attack ';
   str_damage            := 'Damage: ';

   str_cant_build        := 'Can`t build here';
   str_need_energy       := 'Need more energy';
   str_cant_prod         := 'Can`t production this';
   str_check_reqs        := 'Check requirements';
   str_cant_execute      := 'Can`t execute order';
   str_advanced          := 'Advanced ';
   str_unit_advanced     := 'Unit promoted';
   str_upgrade_complete  := 'Upgrade complete';
   str_building_complete := 'Construction complete';
   str_unit_complete     := 'Unit ready';
   str_unit_attacked     := 'Unit is under attack';
   str_base_attacked     := 'Base is under attack';
   str_allies_attacked   := 'Our allies is under attack';
   str_maxlimit_reached  := 'Maximum army limit reached';
   str_need_more_builders:= 'Need more builders';
   str_production_busy   := 'All production is busy';
   str_cant_advanced     := 'Impassible to rebuild/advance';
   str_NeedMoreProd      := 'Nowhere to produce that';
   str_MaximumReached    := 'Maximum reached';
   str_mapMark           := ' put a mark on the map';

   str_attr_unit         := tc_gray  +'unit'        +tc_default;
   str_attr_building     := tc_red   +'building'    +tc_default;
   str_attr_mech         := tc_blue  +'mechanical'  +tc_default;
   str_attr_bio          := tc_orange+'biological'  +tc_default;
   str_attr_light        := tc_yellow+'light'       +tc_default;
   str_attr_heavy        := tc_green +'heavy'       +tc_default;
   str_attr_fly          := tc_white +'flying'      +tc_default;
   str_attr_ground       := tc_lime  +'ground'      +tc_default;
   str_attr_floater      := tc_aqua  +'floater'     +tc_default;
   str_attr_level        := tc_white +'level'       +tc_default;
   str_attr_invuln       := tc_lime  +'invulnerable'+tc_default;
   str_attr_stuned       := tc_yellow+'stuned'      +tc_default;
   str_attr_detector     := tc_purple+'detector'    +tc_default;
   str_attr_transport    := tc_gray  +'transport'   +tc_default;

   str_panelpos          := 'Control panel position';
   str_panelposp[0]      := tc_lime  +'left' +tc_default;
   str_panelposp[1]      := tc_orange+'right'+tc_default;
   str_panelposp[2]      := tc_yellow+'up'   +tc_default;
   str_panelposp[3]      := tc_aqua  +'down' +tc_default;

   str_uhbar             := 'Health bars';
   str_uhbars[0]         := tc_lime  +'selected'+tc_default+'+'+tc_red+'damaged'+tc_default;
   str_uhbars[1]         := tc_aqua  +'always'  +tc_default;
   str_uhbars[2]         := tc_orange+'only '   +tc_lime+'selected'+tc_default;

   str_pcolor            := 'Players colors';
   str_pcolors[0]        := tc_white +'default'+tc_default;
   str_pcolors[1]        := tc_lime  +'own '   +tc_yellow+'ally '+tc_red+'enemy'+tc_default;
   str_pcolors[2]        := tc_white +'own '   +tc_yellow+'ally '+tc_red+'enemy'+tc_default;
   str_pcolors[3]        := tc_white +'own '   +tc_aqua  +'ally '+tc_red+'enemy'+tc_default;
   str_pcolors[4]        := tc_purple+'teams'  +tc_default;
   str_pcolors[5]        := tc_white +'own '   +tc_purple+'teams'+tc_default;

   str_starta            := 'Builders at game start:';

   str_fstarts           := 'Fixed player starts:';

   str_pnua[0]           := tc_aqua  +'x1 '+tc_default+'/'+tc_red+' x1';
   str_pnua[1]           := tc_aqua  +'x2 '+tc_default+'/'+tc_red+' x2';
   str_pnua[2]           := tc_lime  +'x3 '+tc_default+'/'+tc_orange+' x3';
   str_pnua[3]           := tc_lime  +'x4 '+tc_default+'/'+tc_orange+' x4';
   str_pnua[4]           := tc_yellow+'x5 '+tc_default+'/'+tc_yellow+' x5';
   str_pnua[5]           := tc_yellow+'x6 '+tc_default+'/'+tc_yellow+' x6';
   str_pnua[6]           := tc_orange+'x7 '+tc_default+'/'+tc_lime+' x7';
   str_pnua[7]           := tc_orange+'x8 '+tc_default+'/'+tc_lime+' x8';
   str_pnua[8]           := tc_red   +'x9 '+tc_default+'/'+tc_aqua+' x9';
   str_pnua[9]           := tc_red   +'x10'+tc_default+'/'+tc_aqua+' x10';

   str_npnua[0]          := tc_red   +'x1 ';
   str_npnua[1]          := tc_red   +'x2 ';
   str_npnua[2]          := tc_orange+'x3 ';
   str_npnua[3]          := tc_orange+'x4 ';
   str_npnua[4]          := tc_yellow+'x5 ';
   str_npnua[5]          := tc_yellow+'x6 ';
   str_npnua[6]          := tc_lime  +'x7 ';
   str_npnua[7]          := tc_lime  +'x8 ';
   str_npnua[8]          := tc_aqua  +'x9 ';
   str_npnua[9]          := tc_aqua  +'x10';

   str_cmpd[0]           := tc_blue  +'I`m too young to die'+tc_default;
   str_cmpd[1]           := tc_aqua  +'Hey, not too rough'  +tc_default;
   str_cmpd[2]           := tc_lime  +'Hurt me plenty'      +tc_default;
   str_cmpd[3]           := tc_yellow+'Ultra-Violence'      +tc_default;
   str_cmpd[4]           := tc_orange+'Unholy massacre'     +tc_default;
   str_cmpd[5]           := tc_red   +'Nightmare'           +tc_default;
   str_cmpd[6]           := tc_purple+'HELL'                +tc_default;

   str_gmodet            := 'Game mode:';
   str_gmode[gm_scirmish]:= tc_lime  +'Skirmish'        +tc_default;
   str_gmode[gm_3x3     ]:= tc_orange+'3x3'             +tc_default;
   str_gmode[gm_2x2x2   ]:= tc_yellow+'2x2x2'           +tc_default;
   str_gmode[gm_capture ]:= tc_aqua  +'Capturing points'+tc_default;
   str_gmode[gm_invasion]:= tc_blue  +'Invasion'        +tc_default;
   str_gmode[gm_KotH    ]:= tc_purple+'King of the Hill'+tc_default;
   str_gmode[gm_royale  ]:= tc_red   +'Royal Battle'    +tc_default;

   str_cgenerators       := 'Neutral generators:';
   str_cgeneratorsM[0]   := 'none';
   str_cgeneratorsM[1]   := '5 min';
   str_cgeneratorsM[2]   := '10 min';
   str_cgeneratorsM[3]   := '15 min';
   str_cgeneratorsM[4]   := '20 min';
   str_cgeneratorsM[5]   := 'infinity';

   str_team              := 'Team:';
   str_srace             := 'Race:';
   str_ready             := 'Ready: ';
   str_udpport           := 'UDP port:';
   str_svup[false]       := 'Start server';
   str_svup[true ]       := 'Stop server';
   str_connect[false]    := 'Connect';
   str_connect[true ]    := 'Disconnect';
   str_pnu               := 'File size/quality: ';
   str_npnu              := 'Units update rate: ';
   str_connecting        := 'Connecting...';
   str_sver              := 'Wrong version!';
   str_sfull             := 'Server full!';
   str_sgst              := 'Game started!';

   str_hint_t[0]         := 'Buildings';
   str_hint_t[1]         := 'Units';
   str_hint_t[2]         := 'Researches';
   str_hint_t[3]         := 'Controls';

   str_hint_army         := 'Army: ';
   str_hint_energy       := 'Energy: ';

   str_hint_m[0]         := 'Menu (' +tc_lime+'Esc'+tc_default+')';
   str_hint_m[1]         := '';
   str_hint_m[2]         := 'Pause ('+tc_lime+'Pause/Break'+tc_default+')';


   str_ability_name[uab_Teleport        ]:='Teleportation';
   str_ability_name[uab_UACScan         ]:='Scan';
   str_ability_name[uab_HTowerBlink     ]:='Blink';
   str_ability_name[uab_UACStrike       ]:='Missile Strike';
   str_ability_name[uab_HKeepBlink      ]:='Blink';
   str_ability_name[uab_RebuildInPoint  ]:='';
   str_ability_name[uab_HInvulnerability]:='Invulnerability';
   str_ability_name[uab_SpawnLost       ]:='Spawn LostSoul';
   str_ability_name[uab_HellVision      ]:='Hell Vision';
   str_ability_name[uab_CCFly           ]:='Flight Engines';

   _mkHStrUid(UID_HKeep          ,'Hell Keep'                   ,'');
   _mkHStrUid(UID_HAKeep         ,'Great Hell Keep'             ,'');
   _mkHStrUid(UID_HGate          ,'Demon`s Gate'                ,'');
   _mkHStrUid(UID_HSymbol        ,'Unholy Symbol'               ,'');
   _mkHStrUid(UID_HASymbol       ,'Great Unholy Symbol'         ,'');
   _mkHStrUid(UID_HPools         ,'Infernal Pools'              ,'');
   _mkHStrUid(UID_HTeleport      ,'Teleport'                    ,'');
   _mkHStrUid(UID_HPentagram     ,'Pentagram of Death'          ,'');
   _mkHStrUid(UID_HMonastery     ,'Monastery of Despair'        ,'');
   _mkHStrUid(UID_HFortress      ,'Castle of Damned'            ,'');
   _mkHStrUid(UID_HTower         ,'Guard Tower'                 ,'Defensive structure'              );
   _mkHStrUid(UID_HTotem         ,'Totem of Horror'             ,'Advanced defensive structure'     );
   _mkHStrUid(UID_HAltar         ,'Altar of Pain'               ,'');
   _mkHStrUid(UID_HCommandCenter ,'Hell Command Center'         ,'Corrupted Command Center'         );
   _mkHStrUid(UID_HACommandCenter,'Advanced Hell Command Center','Corrupted Advanced Command Center');
   _mkHStrUid(UID_HBarracks      ,'Zombie Barracks'             ,'Corrupted Barracks'               );
   _mkHStrUid(UID_HEye           ,'Evil Eye'                    ,'Passive scouting and detection'   );

   _mkHStrUid(UID_LostSoul       ,'Lost Soul'                   ,'');
   _mkHStrUid(UID_Phantom        ,'Phantom'                     ,'');
   _mkHStrUid(UID_Imp            ,'Imp'                         ,'');
   _mkHStrUid(UID_Demon          ,'Pinky Demon'                 ,'');
   _mkHStrUid(UID_Cacodemon      ,'Cacodemon'                   ,'');
   _mkHStrUid(UID_Knight         ,'Hell Knight'                 ,'');
   _mkHStrUid(UID_Baron          ,'Baron of Hell'               ,'');
   _mkHStrUid(UID_Cyberdemon     ,'Cyberdemon'                  ,'');
   _mkHStrUid(UID_Mastermind     ,'Mastermind'                  ,'');
   _mkHStrUid(UID_Pain           ,'Pain Elemental'              ,'');
   _mkHStrUid(UID_Revenant       ,'Revenant'                    ,'');
   _mkHStrUid(UID_Mancubus       ,'Mancubus'                    ,'');
   _mkHStrUid(UID_Arachnotron    ,'Arachnotron'                 ,'');
   _mkHStrUid(UID_Archvile       ,'Arch-Vile'                   ,'');
   _mkHStrUid(UID_ZFormer        ,'Former Zombie'               ,'');
   _mkHStrUid(UID_ZEngineer      ,'Zombie Engineer'             ,'');
   _mkHStrUid(UID_ZSergant       ,'Zombie Shotguner'            ,'');
   _mkHStrUid(UID_ZSSergant      ,'Zombie SuperShotguner'       ,'');
   _mkHStrUid(UID_ZCommando      ,'Zombie Commando'             ,'');
   _mkHStrUid(UID_ZAntiaircrafter,'Zombie Antiaircrafter'       ,'');
   _mkHStrUid(UID_ZSiegeMarine   ,'Zombie Siege Marine'         ,'');
   _mkHStrUid(UID_ZFPlasmagunner ,'Zombie Plasmaguner'          ,'');
   _mkHStrUid(UID_ZBFGMarine     ,'Zombie BFG Marine'           ,'');


   _mkHStrUpid(upgr_hell_t1attack  ,'Hell Firepower'                ,'Increase the damage of ranged attacks for T1 units and defensive structures.');
   _mkHStrUpid(upgr_hell_uarmor    ,'Combat Flesh'                  ,'Increase the armor of all Hell`s units.'                                 );
   _mkHStrUpid(upgr_hell_barmor    ,'Stone Walls'                   ,'Increase the armor of all Hell`s buildings.'                             );
   _mkHStrUpid(upgr_hell_mattack   ,'Claws and Teeth'               ,'Increase the damage of melee attacks.'                                   );
   _mkHStrUpid(upgr_hell_regen     ,'Flesh Regeneration'            ,'Health regeneration for all Hell`s units.'                               );
   _mkHStrUpid(upgr_hell_pains     ,'Pain Threshold'                ,'Hell units can take more hits before pain stun happen.'                  );
   _mkHStrUpid(upgr_hell_towers    ,'Demonic Spirits'               ,'Increase defensive structures range.'                                    );
   _mkHStrUpid(upgr_hell_HKTeleport,'Hell Keep Blick Charge'        ,'Charge for Hell Keep`s ability.'                                         );
   _mkHStrUpid(upgr_hell_paina     ,'Decay Aura'                    ,'Hell Keep start damage all enemies around. Decay Aura damage ignore unit`s armor.');
   _mkHStrUpid(upgr_hell_buildr    ,'Hell Keep Range Upgrade'       ,'Increase Hell Keep`s sight range.'                                       );
   _mkHStrUpid(upgr_hell_extbuild  ,'Adaptive Foundation'           ,'All buildings, except those that can produce units and Teleport, can be placed on doodads.');
   _mkHStrUpid(upgr_hell_pinkspd   ,'Pinky`s Rage'                  ,'Increase the movement speed of Pinky.'                                   );

   _mkHStrUpid(upgr_hell_spectre   ,'Spectres'                      ,'Pinky become invisible.'                                         );
   _mkHStrUpid(upgr_hell_vision    ,'Hell Sight'                    ,'Increase the sight range of all Hell`s units.'                   );
   _mkHStrUpid(upgr_hell_phantoms  ,'Phantoms'                      ,'Pain Elemental spawns Phantoms instead of Lost Soul.'            );
   _mkHStrUpid(upgr_hell_t2attack  ,'Demon`s Weapons'               ,'Increase the damage of ranged attacks for T2 units and defensive structures'  );
   _mkHStrUpid(upgr_hell_teleport  ,'Teleport Upgrade'              ,'Decrease cooldown time of Teleport.'                             );
   _mkHStrUpid(upgr_hell_rteleport ,'Reverse Teleportation'         ,'Units can teleport back to Teleport.'                            );
   _mkHStrUpid(upgr_hell_heye      ,'Evil Eye Upgrade'              ,'Increase the sight range of Evil Eye.'                           );
   _mkHStrUpid(upgr_hell_totminv   ,'Tower of Horror Invisibility'  ,'Totem of Horror become invisible.'                               );
   _mkHStrUpid(upgr_hell_bldrep    ,'Building Restoration'          ,'Health regeneration for all Hell`s buildings.'                   );
   _mkHStrUpid(upgr_hell_b478tel   ,'Tower Teleportation Charge'    ,'Charges for ability of Guard Tower and Totem of Horror.');
   _mkHStrUpid(upgr_hell_resurrect ,'Resurrection'                  ,'ArchVile`s ability.'                    );
   _mkHStrUpid(upgr_hell_invuln    ,'Invulnerability Sphere'        ,'Charge for Altar of Pain ability.'      );


   _mkHStrUid(UID_UCommandCenter   ,'Command Center'                ,''      );
   _mkHStrUid(UID_UACommandCenter  ,'Advanced Command Center'       ,''      );
   _mkHStrUid(UID_UBarracks        ,'Barracks'                      ,''      );
   _mkHStrUid(UID_UFactory         ,'Vehicle Factory'               ,''      );
   _mkHStrUid(UID_UGenerator       ,'Generator'                     ,''      );
   _mkHStrUid(UID_UAGenerator      ,'Advanced Generator'            ,''      );
   _mkHStrUid(UID_UWeaponFactory   ,'Weapon Factory'                ,''      );
   _mkHStrUid(UID_UGTurret         ,'Anti-ground Turret'            ,'Anti-ground defensive structure');
   _mkHStrUid(UID_UATurret         ,'Anti-air Turret'               ,'Anti-air defensive structure'   );
   _mkHStrUid(UID_UTechCenter      ,'Science Facility'              ,'');
   _mkHStrUid(UID_UNuclearPlant    ,'Nuclear Plant'                 ,'');
   _mkHStrUid(UID_URadar           ,'Radar'                         ,'Reveals map');
   _mkHStrUid(UID_URMStation       ,'Rocket Launcher Station'       ,'');
   _mkHStrUid(UID_UMine            ,'Mine'                          ,'');

   _mkHStrUid(UID_Sergant          ,'Shotguner'                     ,'');
   _mkHStrUid(UID_SSergant         ,'SuperShotguner'                ,'');
   _mkHStrUid(UID_Commando         ,'Commando'                      ,'');
   _mkHStrUid(UID_Antiaircrafter   ,'Antiaircrafter'                ,'');
   _mkHStrUid(UID_SiegeMarine      ,'Siege Marine'                  ,'');
   _mkHStrUid(UID_FPlasmagunner    ,'Plasmaguner'                   ,'');
   _mkHStrUid(UID_BFGMarine        ,'BFG Marine'                    ,'');
   _mkHStrUid(UID_Engineer         ,'Engineer'                      ,'');
   _mkHStrUid(UID_Medic            ,'Medic'                         ,'');
   _mkHStrUid(UID_UTransport       ,'Dropship'                      ,'');
   _mkHStrUid(UID_UACDron          ,'Drone'                         ,'');
   _mkHStrUid(UID_Terminator       ,'Terminator'                    ,'');
   _mkHStrUid(UID_Tank             ,'Tank'                          ,'');
   _mkHStrUid(UID_Flyer            ,'Fighter'                       ,'');
   _mkHStrUid(UID_APC              ,'Ground APC'                    ,'');


   _mkHStrUpid(upgr_uac_attack     ,'Ranged Attack Upgrade'            ,'Increase the damage of ranged attacks for all UAC units and defensive structures.');
   _mkHStrUpid(upgr_uac_uarmor     ,'Infantry Combat Armor Upgrade'    ,'Increase the armor of all Barrack`s units.'                     );
   _mkHStrUpid(upgr_uac_barmor     ,'Concrete Walls'                   ,'Increase the armor of all UAC buildings.'                       );
   _mkHStrUpid(upgr_uac_melee      ,'Advanced Tools'                   ,'Increase the efficiency of repair/healing of Engineers/Medics.' );
   _mkHStrUpid(upgr_uac_mspeed     ,'Lightweight Armor'                ,'Increase the movement speed of all Barrack`s units.'            );
   _mkHStrUpid(upgr_uac_ssgup      ,'Expansive bullets'                ,'Shotguner, SuperShotguner and Terminator deal more damage to ['+str_attr_bio+'].' );
   _mkHStrUpid(upgr_uac_towers     ,'Tower Range Upgrade'              ,'Increase defensive structures range.'                           );
   _mkHStrUpid(upgr_uac_CCFly      ,'Command Center Flight Engines'    ,'Command Center gains ability to fly.'                           );
   _mkHStrUpid(upgr_uac_ccturr     ,'Command Center Turret'            ,'Plasma turret for Command Center.'                              );
   _mkHStrUpid(upgr_uac_buildr     ,'Command Center Range Upgrade'     ,'Increase Command Center sight range.'                           );
   _mkHStrUpid(upgr_uac_extbuild   ,'Adaptive Foundation'              ,'All buildings, except those that can produce units, can be placed on doodads.');
   _mkHStrUpid(upgr_uac_soaring    ,'Engines for Soaring'              ,'Drone can move over obstacles.'              );

   _mkHStrUpid(upgr_uac_botturret  ,'Drone Transformation Protocol'    ,'Drone can rebuild to Anti-ground turret.'    );
   _mkHStrUpid(upgr_uac_vision     ,'Light Amplification Visors'       ,'Increase the sight range of all UAC units.'  );
   _mkHStrUpid(upgr_uac_commando   ,'Stealth Technology'               ,'Commando become invisible.'                  );
   _mkHStrUpid(upgr_uac_airsp      ,'Fragmentation Missiles'           ,'Anti-air missiles deal additional damage around target.'  );
   _mkHStrUpid(upgr_uac_mechspd    ,'Advanced Engines'                 ,'Increase the movement speed of all Factory`s units.'      );
   _mkHStrUpid(upgr_uac_mecharm    ,'Mech Combat Armor Upgrade'        ,'Increase the armor of all Factory`s units.'               );
   _mkHStrUpid(upgr_uac_lturret    ,'Fighter Laser Gun'                ,'Fighter anti-ground weapon.'                              );
   _mkHStrUpid(upgr_uac_transport  ,'Dropship Upgrade'                 ,'Increase the capacity of Dropship'                    );
   _mkHStrUpid(upgr_uac_radar_r    ,'Radar Upgrade'                    ,'Increase radar scouting radius.'             );
   _mkHStrUpid(upgr_uac_plasmt     ,'Anti-ground Plasmagun'            ,'Plasmagun for Anti-ground turret.'           );
   _mkHStrUpid(upgr_uac_turarm     ,'Additional Armoring'              ,'Additional armor for Turrets.'               );
   _mkHStrUpid(upgr_uac_rstrike    ,'Rocket Strike Charge'             ,'Charge for Rocket Launcher Station ability.' );


   _mkHStrACT(0 ,'Action');
   _mkHStrACT(1 ,'Action at point');
   _mkHStrACT(2 ,'Rebuild/Advance');
   t:='attack enemies';
   _mkHStrACT(3 ,'Move, '  +t);
   _mkHStrACT(4 ,'Stop, '  +t);
   _mkHStrACT(5 ,'Patrol, '+t);
   t:='ignore enemies';
   _mkHStrACT(6 ,'Move, '  +t);
   _mkHStrACT(7 ,'Stop, '  +t);
   _mkHStrACT(8 ,'Patrol, '+t);
   _mkHStrACT(9 ,'Cancel production');
   _mkHStrACT(10,'Select all units' );
   _mkHStrACT(11,'Destroy'          );
   _mkHStrACT(12,'Alarm mark'       );
   _mkHStrACT(13,str_maction);

   _mkHStrRPL(0 ,'Faster game speed'    ,false);
   _mkHStrRPL(1 ,'Left click: skip 2 seconds ('                                +tc_lime+'W'+tc_default+')'+tc_nl1+
                 'Right click: skip 10 seconds ('+tc_lime+'Ctrl'+tc_default+'+'+tc_lime+'W'+tc_default+')'+tc_nl1+
                 'Skip 1 minute ('               +tc_lime+'Alt' +tc_default+'+'+tc_lime+'W'+tc_default+')',true);
   _mkHStrRPL(2 ,'Pause'                ,false);
   _mkHStrRPL(3 ,'Player POV'           ,false);
   _mkHStrRPL(4 ,'List of game messages',false);
   _mkHStrRPL(5 ,'Fog of war'           ,false);
   _mkHStrRPL(8 ,'All players',false);
   _mkHStrRPL(9 ,'Player #1'  ,false);
   _mkHStrRPL(10,'Player #2'  ,false);
   _mkHStrRPL(11,'Player #3'  ,false);
   _mkHStrRPL(12,'Player #4'  ,false);
   _mkHStrRPL(13,'Player #5'  ,false);
   _mkHStrRPL(14,'Player #6'  ,false);

   _mkHStrOBS(0 ,'Fog of war' ,false);
   _mkHStrOBS(2 ,'All players',false);
   _mkHStrOBS(3 ,'Player #1'  ,false);
   _mkHStrOBS(4 ,'Player #2'  ,false);
   _mkHStrOBS(5 ,'Player #3'  ,false);
   _mkHStrOBS(6 ,'Player #4'  ,false);
   _mkHStrOBS(7 ,'Player #5'  ,false);
   _mkHStrOBS(8 ,'Player #6'  ,false);


   {str_camp_t[0]         := 'Hell #1: Phobos invasion';
   str_camp_t[1]         := 'Hell #2: Military base';
   str_camp_t[2]         := 'Hell #3: Deimos invasion';
   str_camp_t[3]         := 'Hell #4: Pentagram of Death';
   str_camp_t[4]         := 'Hell #7: Quarry';
   str_camp_t[5]         := 'Hell #8: Hell on Mars';
   str_camp_t[6]         := 'Hell #5: Hell on Earth';
   str_camp_t[7]         := 'Hell #6: Cosmodrome';
   str_camp_t[8]         := '9. ';
   str_camp_t[9]         := '10. ';
   str_camp_t[10]        := '11. ';
   str_camp_t[11]        := '12. ';
   str_camp_t[12]        := '13. ';
   str_camp_t[13]        := '14. ';
   str_camp_t[14]        := '15. ';
   str_camp_t[15]        := '16. ';
   str_camp_t[16]        := '17. ';
   str_camp_t[17]        := '18. ';
   str_camp_t[18]        := '19. ';
   str_camp_t[19]        := '20. ';
   str_camp_t[20]        := '21. ';
   str_camp_t[21]        := '22. ';

   str_camp_o[0]         := '-Destroy all human bases and armies'+tc_nl3+'-Protect the Portal';
   str_camp_o[1]         := '-Destroy Military Base';
   str_camp_o[2]         := '-Destroy all human bases and armies'+tc_nl3+'-Protect the Portal';
   str_camp_o[3]         := '-Protect the altars for 20 minutes';
   str_camp_o[4]         := '-Destroy all human bases and armies';
   str_camp_o[5]         := '-Destroy all human bases and armies';
   str_camp_o[6]         := '-Destroy all human bases and armies';
   str_camp_o[7]         := '-Destroy Cosmodrome'+tc_nl3+'-No one human`s transport should escape';

   str_camp_m[0]         := tc_lime+'Date:'+tc_default+tc_nl2+'15.11.2145'+tc_nl2+tc_lime+'Location:'+tc_default+tc_nl2+'PHOBOS'+tc_nl2+tc_lime+'Area:'+tc_default+tc_nl2+'Anomaly Zone';
   str_camp_m[1]         := tc_lime+'Date:'+tc_default+tc_nl2+'16.11.2145'+tc_nl2+tc_lime+'Location:'+tc_default+tc_nl2+'PHOBOS'+tc_nl2+tc_lime+'Area:'+tc_default+tc_nl2+'Hall crater';
   str_camp_m[2]         := tc_lime+'Date:'+tc_default+tc_nl2+'15.11.2145'+tc_nl2+tc_lime+'Location:'+tc_default+tc_nl2+'DEIMOS'+tc_nl2+tc_lime+'Area:'+tc_default+tc_nl2+'Anomaly Zone';
   str_camp_m[3]         := tc_lime+'Date:'+tc_default+tc_nl2+'16.11.2145'+tc_nl2+tc_lime+'Location:'+tc_default+tc_nl2+'DEIMOS'+tc_nl2+tc_lime+'Area:'+tc_default+tc_nl2+'Swift crater';
   str_camp_m[4]         := tc_lime+'Date:'+tc_default+tc_nl2+'18.11.2145'+tc_nl2+tc_lime+'Location:'+tc_default+tc_nl2+'MARS'  +tc_nl2+tc_lime+'Area:'+tc_default+tc_nl2+'Hellas Area';
   str_camp_m[5]         := tc_lime+'Date:'+tc_default+tc_nl2+'19.11.2145'+tc_nl2+tc_lime+'Location:'+tc_default+tc_nl2+'MARS'  +tc_nl2+tc_lime+'Area:'+tc_default+tc_nl2+'Hellas Area';
   str_camp_m[6]         := tc_lime+'Date:'+tc_default+tc_nl2+'18.11.2145'+tc_nl2+tc_lime+'Location:'+tc_default+tc_nl2+'EARTH' +tc_nl2+tc_lime+'Area:'+tc_default+tc_nl2+'Unknown';
   str_camp_m[7]         := tc_lime+'Date:'+tc_default+tc_nl2+'19.11.2145'+tc_nl2+tc_lime+'Location:'+tc_default+tc_nl2+'EARTH' +tc_nl2+tc_lime+'Area:'+tc_default+tc_nl2+'Unknown';  }

   {
   str_cmp_mn[1 ] := 'Hell #1: Invasion on Phobos';
   str_cmp_mn[2 ] := 'Hell #2: Toxin Refinery';
   str_cmp_mn[3 ] := 'Hell #3: Military Base';
   str_cmp_mn[4 ] := 'Hell #4: Deimos Anomaly';
   str_cmp_mn[5 ] := 'Hell #5: Nuclear Plant';
   str_cmp_mn[6 ] := 'Hell #6: Science Center';
   str_cmp_mn[7 ] := 'Hell #7: Quarry';
   str_cmp_mn[8 ] := 'Hell #8: Hell on Mars';
   str_cmp_mn[9 ] := 'Hell #9: Hell On Earth';
   str_cmp_mn[10] := 'Hell #10: Industrial Zone';
   str_cmp_mn[11] := 'Hell tc_nl1: Cosmodrome';
   str_cmp_mn[12] := 'UAC #1: Command Center';
   str_cmp_mn[13] := 'UAC #2: Super Generators';
   str_cmp_mn[14] := 'UAC #3: Phobos Anomaly';
   str_cmp_mn[15] := 'UAC #4: Deimos Anomaly 2';
   str_cmp_mn[16] := 'UAC #5: Lab';
   str_cmp_mn[17] := 'UAC #6: Fortress of Mystery';
   str_cmp_mn[18] := 'UAC #7: City of the Damned';
   str_cmp_mn[19] := 'UAC #8: Slough of Despair';
   str_cmp_mn[20] := 'UAC #9: Mt. Erebus';
   str_cmp_mn[21] := 'UAC #10: Dead Zone';
   str_cmp_mn[22] := 'UAC tc_nl1: Battle For Mars';

   str_cmp_ob[1 ] := '-Destroy all human bases and armies'+tc_nl3+'-Protect portal';
   str_cmp_ob[2 ] := '-Destroy Toxin Refinery';
   str_cmp_ob[3 ] := '-Destroy Military Base';
   str_cmp_ob[4 ] := '-Destroy all human bases and armies'+tc_nl3+'-Cyberdemon must survive'+tc_nl3+'-Protect portal';
   str_cmp_ob[5 ] := '-Destroy Nuclear Plant'+tc_nl3+'-Cyberdemon must survive';
   str_cmp_ob[6 ] := '-Destroy Science Center'+tc_nl3+'-Cyberdemon must survive';
   str_cmp_ob[7 ] := '-Destroy all human bases and armies';
   str_cmp_ob[8 ] := '-Kill all humans!';
   str_cmp_ob[9 ] := '-Protect Hell Fortess'+tc_nl3+'-Destroy all human towns and armies';
   str_cmp_ob[10] := '-Destroy all industrial buildings'+tc_nl3+'-Destroy all command centers';
   str_cmp_ob[11] := '-Destroy all military bases';
   str_cmp_ob[12] := '-Find, protect and reapir'+tc_nl3+'Command Center'+tc_nl3+'-At least one engineer must survive';
   str_cmp_ob[13] := '-Find and repair 5 Super Generators';
   str_cmp_ob[14] := '-Destroy all bases and armies of hell'+tc_nl3+'around portal until the arrival of'+tc_nl3+'enemy reinforcements(for 20 minutes)';
   str_cmp_ob[15] := '-Destroy all bases and armies of hell'+tc_nl3+'-Protect portal';
   str_cmp_ob[16] := '-Repair and protect Science Center'+tc_nl3+'-Destroy all bases and armies of hell';
   str_cmp_ob[17] := '-Destroy fortess of hell';
   str_cmp_ob[18] := '-Destroy all altars of hell'+tc_nl3+'-Protect portal';
   str_cmp_ob[19] := '-Reach the opposite side of the area';
   str_cmp_ob[20] := '-Find and kill the Spiderdemon';
   str_cmp_ob[21] := '-Cleanse the Quarry';
   str_cmp_ob[22] := '-Destroy all bases and armies of hell';

   str_cmp_map[1 ] := 'Date:'+tc_nl2+'15.11.2145'+tc_nl2+'Location:'+tc_nl2+'PHOBOS'+tc_nl2+'Area:'+tc_nl2+'Anomaly Zone';
   str_cmp_map[2 ] := 'Date:'+tc_nl2+'15.11.2145'+tc_nl2+'Location:'+tc_nl2+'PHOBOS'+tc_nl2+'Area:'+tc_nl2+'Hall crater';
   str_cmp_map[3 ] := 'Date:'+tc_nl2+'16.11.2145'+tc_nl2+'Location:'+tc_nl2+'PHOBOS'+tc_nl2+'Area:'+tc_nl2+'Drunlo crater';
   str_cmp_map[4 ] := 'Date:'+tc_nl2+'15.11.2145'+tc_nl2+'Location:'+tc_nl2+'DEIMOS'+tc_nl2+'Area:'+tc_nl2+'Anomaly Zone';
   str_cmp_map[5 ] := 'Date:'+tc_nl2+'16.11.2145'+tc_nl2+'Location:'+tc_nl2+'DEIMOS'+tc_nl2+'Area:'+tc_nl2+'Swift crater';
   str_cmp_map[6 ] := 'Date:'+tc_nl2+'16.11.2145'+tc_nl2+'Location:'+tc_nl2+'DEIMOS'+tc_nl2+'Area:'+tc_nl2+'Voltaire Area';
   str_cmp_map[7 ] := 'Date:'+tc_nl2+'16.11.2145'+tc_nl2+'Location:'+tc_nl2+'MARS'  +tc_nl2+'Area:'+tc_nl2+'Hellas Area';
   str_cmp_map[8 ] := 'Date:'+tc_nl2+'16.11.2145'+tc_nl2+'Location:'+tc_nl2+'MARS'  +tc_nl2+'Area:'+tc_nl2+'Hellas Area';
   str_cmp_map[9 ] := 'Date:'+tc_nl2+'25.11.2145'+tc_nl2+'Location:'+tc_nl2+'EARTH' +tc_nl2+'Area:'+tc_nl2+'Unknown';
   str_cmp_map[10] := 'Date:'+tc_nl2+'26.11.2145'+tc_nl2+'Location:'+tc_nl2+'EARTH' +tc_nl2+'Area:'+tc_nl2+'Unknown';
   str_cmp_map[11] := 'Date:'+tc_nl2+'27.11.2145'+tc_nl2+'Location:'+tc_nl2+'EARTH' +tc_nl2+'Area:'+tc_nl2+'Unknown';
   str_cmp_map[12] := 'Date:'+tc_nl2+'16.11.2145'+tc_nl2+'Location:'+tc_nl2+'PHOBOS'+tc_nl2+'Area:'+tc_nl2+'Todd crater';
   str_cmp_map[13] := 'Date:'+tc_nl2+'16.11.2145'+tc_nl2+'Location:'+tc_nl2+'PHOBOS'+tc_nl2+'Area:'+tc_nl2+'Roche crater';
   str_cmp_map[14] := 'Date:'+tc_nl2+'17.11.2145'+tc_nl2+'Location:'+tc_nl2+'PHOBOS'+tc_nl2+'Area:'+tc_nl2+'Anomaly Zone';
   str_cmp_map[15] := 'Date:'+tc_nl2+'17.11.2145'+tc_nl2+'Location:'+tc_nl2+'DEIMOS'+tc_nl2+'Area:'+tc_nl2+'Anomaly Zone';
   str_cmp_map[16] := 'Date:'+tc_nl2+'18.11.2145'+tc_nl2+'Location:'+tc_nl2+'DEIMOS'+tc_nl2+'Area:'+tc_nl2+'Voltaire Area';
   str_cmp_map[17] := 'Date:'+tc_nl2+'18.11.2145'+tc_nl2+'Location:'+tc_nl2+'DEIMOS'+tc_nl2+'Area:'+tc_nl2+'Voltaire Area';
   str_cmp_map[18] := 'Date:'+tc_nl2+'20.11.2145'+tc_nl2+'Location:'+tc_nl2+'HELL'  +tc_nl2+'Area:'+tc_nl2+'Unknown';
   str_cmp_map[19] := 'Date:'+tc_nl2+'21.11.2145'+tc_nl2+'Location:'+tc_nl2+'HELL'  +tc_nl2+'Area:'+tc_nl2+'Unknown';
   str_cmp_map[20] := 'Date:'+tc_nl2+'22.11.2145'+tc_nl2+'Location:'+tc_nl2+'HELL'  +tc_nl2+'Area:'+tc_nl2+'Unknown';
   str_cmp_map[21] := 'Date:'+tc_nl2+'21.11.2145'+tc_nl2+'Location:'+tc_nl2+'MARS'  +tc_nl2+'Area:'+tc_nl2+'Hellas Area';
   str_cmp_map[22] := 'Date:'+tc_nl2+'22.11.2145'+tc_nl2+'Location:'+tc_nl2+'MARS'  +tc_nl2+'Area:'+tc_nl2+'Hellas Area';
   }

   _makeHints;
end;

procedure lng_rus;
var t: shortstring;
begin
  str_MMap              := 'КАРТА';
  str_MPlayers          := 'ИГРОКИ';
  str_MObjectives       := 'ЗАДАЧИ';
  str_menu_s1[ms1_sett] := 'НАСТРОЙКИ';
  str_menu_s1[ms1_svld] := 'СОХР./ЗАГР.';
  str_menu_s1[ms1_reps] := 'ЗАПИСИ';
  str_menu_s2[ms2_camp] := 'КАМПАНИИ';
  str_menu_s2[ms2_scir] := 'СХВАТКА';
  str_menu_s2[ms2_mult] := 'СЕТЕВАЯ ИГРА';
  str_menu_s3[ms3_game] := 'ИГРА';
  str_menu_s3[ms3_vido] := 'ГРАФИКА';
  str_menu_s3[ms3_sond] := 'ЗВУК';
  str_reset[false]      := 'НАЧАТЬ';
  str_reset[true ]      := 'СБРОС';
  str_exit[false]       := 'ВЫХОД';
  str_exit[true]        := 'НАЗАД';
  str_m_liq             := 'Озера: ';
  str_m_siz             := 'Размер: ';
  str_m_obs             := 'Преграды: ';
  str_m_sym             := 'Симметр.: ';
  str_map               := 'Карта';
  str_players           := 'Игроки';
  str_mrandom           := 'Случайная карта';
  str_musicvol          := 'Громкость музыки';
  str_soundvol          := 'Громкость звуков';
  str_scrollspd         := 'Скорость пр.';
  str_mousescrl         := 'Прокр. мышью';
  str_fullscreen        := 'В окне:';
  str_plname            := 'Имя игрока';
  str_maction           := 'Действие на правый клик';
  str_maction2[true ]   := tc_lime+'движение'+tc_default;
  str_maction2[false]   := tc_lime+'движ.'   +tc_default+'+'+tc_red+'атака'+tc_default;
  str_race[r_random]    := tc_white+'ЛЮБАЯ'  +tc_default;
  str_observer          := 'ЗРИТЕЛЬ';
  str_pause             := 'Пауза';
  str_win               := 'ПОБЕДА!';
  str_lose              := 'ПОРАЖЕНИЕ!';
  str_gsunknown         := 'Неизвестный статус!';
  str_gsaved            := 'Игра сохранена';
  str_repend            := 'Конец записи!';
  str_save              := 'Сохранить';
  str_load              := 'Загрузить';
  str_delete            := 'Удалить';
  str_svld_errors_file  := 'Файл не'+tc_nl3+'существует!';
  str_svld_errors_open  := 'Невозможно'+tc_nl3+'открыть файл!';
  str_svld_errors_wdata := 'Неправильный'+tc_nl3+'размер файла!';
  str_svld_errors_wver  := 'Неправильная'+tc_nl3+'версия файла!';
  str_time              := 'Время: ';
  str_menu              := 'Меню';
  str_player_def        := ' уничтожен!';
  str_inv_time          := 'Волна #';
  str_inv_ml            := 'Армия монстров: ';
  str_play              := 'Проиграть';
  str_replay            := 'ЗАПИСЬ';
  str_replay_name       := 'Название записи:';
  str_cmpdif            := 'Сложность: ';
  str_waitsv            := 'Ожидание сервера...';
  str_goptions          := 'ПАРАМЕТРЫ ИГРЫ';
  str_server            := 'СЕРВЕР';
  str_client            := 'КЛИЕНТ';
  str_menu_chat         := 'ЧАТ(ВСЕ ИГРОКИ)';
  str_chat_all          := 'ВСЕ:';
  str_chat_allies       := 'СОЮЗНИКИ:';
  str_randoms           := 'Случайная схватка';
  str_apply             := 'применить';
  str_plout             := ' покинул игру';
  str_aislots           := 'Заполнить пустые слоты:';
  str_resol             := 'Разрешение';
  str_language          := 'Язык интерфейса';
  str_req               := 'Требования: ';
  str_orders            := 'Отряды: ';
  str_all               := 'Все';
  str_uprod             := tc_lime+'Создается в: '+tc_default;
  str_bprod             := tc_lime+'Строит: '     +tc_default;
  str_ColoredShadow     := 'Цветные тени';
  str_kothtime          := 'Время до захвата центра: ';
  str_kothwinner        := ' - Царь Горы!';
  str_DeadObservers     := 'Наблюдатель после поражения:';
  str_FPS               := 'Показать FPS';
  str_APM               := 'Показать APM';
  str_ability           := 'Способность: ';
  str_transformation    := 'превращение в ';
  str_upgradeslvl       := 'Улучшения: ';

  str_builder           := 'Строитель';
  str_barrack           := 'Производит юнитов';
  str_smith             := 'Исследует улучшения и апгрейды';
  str_IncEnergyLevel    := 'Увеличивает уровень энергии';
  str_CanRebuildTo      := 'Можно перестроить в ';
  str_canattack         := 'Может атаковать ';
  str_damage            := 'Урон: ';

  str_cant_build        := 'Нельзя строить здесь';
  str_need_energy       := 'Необходимо больше энергии';
  str_cant_prod         := 'Невоможно произвести это';
  str_check_reqs        := 'Проверьте требования';
  str_cant_execute      := 'Невозвможно выполнить приказ';
  str_advanced          := 'Улучшенный ';
  str_unit_advanced     := 'Юнит улучшен';
  str_upgrade_complete  := 'Исследование завершено';
  str_building_complete := 'Постройка завершена';
  str_unit_complete     := 'Юнит готов';
  str_unit_attacked     := 'Юнит атакован';
  str_base_attacked     := 'База атакована';
  str_allies_attacked   := 'Наши союзники атакованы';
  str_maxlimit_reached  := 'Достигнут максимальный размер армии';
  str_need_more_builders:= 'Необходимо больше строителей';
  str_production_busy   := 'Все производства заняты';
  str_cant_advanced     := 'Невозможно перестроить/улучшить';
  str_NeedMoreProd      := 'Негде производить это';
  str_MaximumReached    := 'Достигнут максимум';
  str_mapMark           := ' поставил отметку на карте';

  str_attr_unit         := tc_gray  +'юнит'          +tc_default;
  str_attr_building     := tc_red   +'здание'        +tc_default;
  str_attr_mech         := tc_blue  +'механический'  +tc_default;
  str_attr_bio          := tc_orange+'биологический' +tc_default;
  str_attr_light        := tc_yellow+'легкий'        +tc_default;
  str_attr_heavy        := tc_green +'тяжелый'       +tc_default;
  str_attr_fly          := tc_white +'летающий'      +tc_default;
  str_attr_ground       := tc_lime  +'наземный'      +tc_default;
  str_attr_floater      := tc_aqua  +'парящий'       +tc_default;
  str_attr_level        := tc_white +'уровень '      +tc_default;
  str_attr_invuln       := tc_lime  +'неуязвимый'    +tc_default;
  str_attr_stuned       := tc_yellow+'оглушен'       +tc_default;
  str_attr_detector     := tc_purple+'детектор'      +tc_default;
  str_attr_transport    := tc_gray  +'транспорт'     +tc_default;

  str_panelpos          := 'Положение игровой панели';
  str_panelposp[0]      := tc_lime  +'слева' +tc_default;
  str_panelposp[1]      := tc_orange+'справа'+tc_default;
  str_panelposp[2]      := tc_yellow+'вверху'+tc_default;
  str_panelposp[3]      := tc_aqua  +'внизу' +tc_default;

  str_uhbar             := 'Полоски здоровья';
  str_uhbars[0]         := tc_lime  +'выбранные'+tc_default+'+'+tc_red+'поврежд.'+tc_default;
  str_uhbars[1]         := tc_aqua  +'всегда'   +tc_default;
  str_uhbars[2]         := tc_orange+'только '  +tc_lime+'выбранные'+tc_default;

  str_pcolor            := 'Цвета игроков';
  str_pcolors[0]        := tc_white +'по умолчанию'+tc_default;
  str_pcolors[1]        := tc_lime  +'свои '+tc_yellow+'союзники '+tc_red+'враги'+tc_default;
  str_pcolors[2]        := tc_white +'свои '+tc_yellow+'союзники '+tc_red+'враги'+tc_default;
  str_pcolors[3]        := tc_purple+'команды'+tc_default;
  str_pcolors[4]        := tc_white +'свои '+tc_purple+'команды'+tc_default;

  str_starta            := 'Количество строителей на старте:';

  str_fstarts           := 'Фиксированные старты:';

  str_gmodet            := 'Режим игры:';
  str_gmode[gm_scirmish]:= tc_lime  +'Схватка'           +tc_default;
  str_gmode[gm_3x3     ]:= tc_orange+'3x3'               +tc_default;
  str_gmode[gm_2x2x2   ]:= tc_yellow+'2x2x2'             +tc_default;
  str_gmode[gm_capture ]:= tc_aqua  +'Захват точек'      +tc_default;
  str_gmode[gm_invasion]:= tc_blue  +'Вторжение'         +tc_default;
  str_gmode[gm_KotH    ]:= tc_purple+'Царь горы'         +tc_default;
  str_gmode[gm_royale  ]:= tc_red   +'Королевская битва' +tc_default;

  str_cgenerators       := 'Нейтральные генераторы:';
  str_cgeneratorsM[0]   := 'нет';
  str_cgeneratorsM[1]   := '5 мин.';
  str_cgeneratorsM[2]   := '10 мин.';
  str_cgeneratorsM[3]   := '15 мин.';
  str_cgeneratorsM[4]   := '20 мин.';
  str_cgeneratorsM[5]   := 'бесконечные';

  str_team              := 'Клан:';
  str_srace             := 'Раса:';
  str_ready             := 'Готов: ';
  str_udpport           := 'UDP порт:';
  str_svup[false]       := 'Вкл. сервер';
  str_svup[true ]       := 'Выкл. сервер';
  str_connect[false]    := 'Подключится';
  str_connect[true ]    := 'Откл.';
  str_pnu               := 'Размер/качество: ';
  str_npnu              := 'Обновление юнитов: ';
  str_connecting        := 'Соединение...';
  str_sver              := 'Другая версия!';
  str_sfull             := 'Нет мест!';
  str_sgst              := 'Игра началась!';

  str_hint_t[0]         := 'Здания';
  str_hint_t[1]         := 'Юниты';
  str_hint_t[2]         := 'Исследования';
  str_hint_t[3]         := 'Запись';

  str_hint_m[0]         := 'Меню (' +tc_lime+'Esc'        +tc_default+')';
  str_hint_m[2]         := 'Пауза ('+tc_lime+'Pause/Break'+tc_default+')';

  str_hint_army         := 'Армия: ';
  str_hint_energy       := 'Энергия: ';

  str_ability_name[uab_Teleport        ]:='Телепортация';
  str_ability_name[uab_UACScan         ]:='Сканирование';
  str_ability_name[uab_HTowerBlink     ]:='Скачок';
  str_ability_name[uab_UACStrike       ]:='Ракетный удар';
  str_ability_name[uab_HKeepBlink      ]:='Перемещение';
  str_ability_name[uab_RebuildInPoint  ]:='';
  str_ability_name[uab_HInvulnerability]:='Неуязвимость';
  str_ability_name[uab_SpawnLost       ]:='Выпустить Lost Soul';
  str_ability_name[uab_HellVision      ]:='Адское зрение';
  str_ability_name[uab_CCFly           ]:='Двигатели для полета';


  _mkHStrUid(UID_HKeep           ,'Адская Крепость'            ,'');
  _mkHStrUid(UID_HAKeep          ,'Великая Адская Крепость'    ,'');
  _mkHStrUid(UID_HGate           ,'Врата Демонов'              ,'');
  _mkHStrUid(UID_HSymbol         ,'Нечестивый Символ'          ,'');
  _mkHStrUid(UID_HASymbol        ,'Великий Нечестивый Символ'  ,'');
  _mkHStrUid(UID_HPools          ,'Инфернальные Омуты'         ,'');
  _mkHStrUid(UID_HTeleport       ,'Телепорт'                   ,'');
  _mkHStrUid(UID_HPentagram      ,'Пентаграмма Смерти'         ,'');
  _mkHStrUid(UID_HMonastery      ,'Монастырь Отчаяния'         ,'');
  _mkHStrUid(UID_HFortress       ,'Замок Проклятых'            ,'');
  _mkHStrUid(UID_HTower          ,'Сторожевая Башня'           ,'Защитное сооружение'                  );
  _mkHStrUid(UID_HTotem          ,'Тотем Ужаса'                ,'Продвинутое защитное сооружение'      );
  _mkHStrUid(UID_HAltar          ,'Алтарь Боли'                ,'');
  _mkHStrUid(UID_HCommandCenter  ,'Проклятый Командный Центр'  ,''         );
  _mkHStrUid(UID_HACommandCenter ,'Продвинутый Проклятый Командный Центр','');
  _mkHStrUid(UID_HBarracks       ,'Казармы Зомби'              ,''          );
  _mkHStrUid(UID_HEye            ,'Око Зла'                    ,''       );


  _mkHStrUid(UID_UCommandCenter  ,'Командный Центр'            ,'');
  _mkHStrUid(UID_UACommandCenter ,'Продвинутый Командный Центр','');
  _mkHStrUid(UID_UBarracks       ,'Казармы'                    ,'');
  _mkHStrUid(UID_UFactory        ,'Фабрика'                    ,'');
  _mkHStrUid(UID_UGenerator      ,'Генератор'                  ,'');
  _mkHStrUid(UID_UAGenerator     ,'Продвинутый Генератор'      ,'');
  _mkHStrUid(UID_UWeaponFactory  ,'Завод Вооружений'           ,'');
  _mkHStrUid(UID_UGTurret        ,'Анти-наземная Турель'       ,'Анти-наземное защитное сооружение'           );
  _mkHStrUid(UID_UATurret        ,'Анти-воздушная Турель'      ,'Анти-воздушное защитное сооружение'          );
  _mkHStrUid(UID_UTechCenter     ,'Научный Центр'              ,'Открывает доступ к T2 технологиям для юнитов');
  _mkHStrUid(UID_UNuclearPlant   ,'АЭС'                        ,'Открывает доступ к T2 технологиям для зданий');
  _mkHStrUid(UID_URadar          ,'Радар'                      ,'Разведует карту. Детектор'                   );
  _mkHStrUid(UID_URMStation      ,'Станция Ракетного Залпа'    ,'Производит ракетный удар. Для залпа требуется исследование "Ракетный удар"');
  _mkHStrUid(UID_UMine           ,'Мина'                       ,'');

  _mkHStrUid(UID_Sergant         ,'Сержант'                ,'');
  _mkHStrUid(UID_SSergant        ,'Старший Сержант'        ,'');
  _mkHStrUid(UID_Commando        ,'Коммандо'               ,'');
  _mkHStrUid(UID_Antiaircrafter  ,'Зенитчик'               ,'');
  _mkHStrUid(UID_SiegeMarine     ,'Артиллерист'            ,'');
  _mkHStrUid(UID_FPlasmagunner   ,'Плазмаганнер'           ,'');
  _mkHStrUid(UID_BFGMarine       ,'Солдат с BFG'           ,'');
  _mkHStrUid(UID_Engineer        ,'Инженер'                ,'');
  _mkHStrUid(UID_Medic           ,'Медик'                  ,'');
  _mkHStrUid(UID_UACDron         ,'Дрон'                   ,'');
  _mkHStrUid(UID_UTransport      ,'Десантный корабль'      ,'');
  _mkHStrUid(UID_Terminator      ,'Терминатор'             ,'');
  _mkHStrUid(UID_Tank            ,'Танк'                   ,'');
  _mkHStrUid(UID_Flyer           ,'Истребитель'            ,'');
  _mkHStrUid(UID_APC             ,'БТР'                    ,'');



  _mkHStrACT(0 ,'Действие'            );
  _mkHStrACT(1 ,'Действие в точке'    );
  _mkHStrACT(2 ,'Перестроить/Улучшить');
  t:='атаковать врагов';
  _mkHStrACT(3 ,'Двигаться, '       +t);
  _mkHStrACT(4 ,'Стоять, '          +t);
  _mkHStrACT(5 ,'Патрулировать, '   +t);
  t:='игнорировать врагов';
  _mkHStrACT(6 ,'Двигаться, '       +t);
  _mkHStrACT(7 ,'Стоять, '          +t);
  _mkHStrACT(8 ,'Патрулировать, '   +t);
  _mkHStrACT(9 ,'Отмена производства' );
  _mkHStrACT(10,'Выбрать всех боевых незанятых юнитов');
  _mkHStrACT(11,'Уничтожить'          );
  _mkHStrACT(12,'Поставить метку'     );
  _mkHStrACT(13,str_maction           );

  _mkHStrRPL(0 ,'Включить/выключить ускоренный просмотр',false);
  _mkHStrRPL(1 ,'Левый клик: пропустить 2 секунды ('                               +tc_lime+'W'+tc_default+')'+tc_nl1+
                'Правый клик: пропустить 10 секунд ('+tc_lime+'Ctrl'+tc_default+'+'+tc_lime+'W'+tc_default+')'+tc_nl1+
                'Пропустить 1 минуту ('              +tc_lime+'Alt' +tc_default+'+'+tc_lime+'W'+tc_default+')',true  );
  _mkHStrRPL(2 ,'Пауза'                   ,false);
  _mkHStrRPL(3 ,'Камера игрока'           ,false);
  _mkHStrRPL(4 ,'Список игровых сообщений',false);
  _mkHStrRPL(5 ,'Туман войны'             ,false);
  _mkHStrRPL(8 ,'Все игроки'              ,false);
  _mkHStrRPL(9 ,'Игрок #1',false);
  _mkHStrRPL(10,'Игрок #2',false);
  _mkHStrRPL(11,'Игрок #3',false);
  _mkHStrRPL(12,'Игрок #4',false);
  _mkHStrRPL(13,'Игрок #5',false);
  _mkHStrRPL(14,'Игрок #6',false);


  {str_camp_t[0]         := 'Hell #1: Вторжение на Фобос';
  str_camp_t[1]         := 'Hell #2: Военная база';
  str_camp_t[2]         := 'Hell #3: Вторжение на Деймос';
  str_camp_t[3]         := 'Hell #4: Пентаграмма смерти';
  str_camp_t[4]         := 'Hell #7: Каньон';
  str_camp_t[5]         := 'Hell #8: Ад на Марсе';
  str_camp_t[6]         := 'Hell #5: Ад на Земле';
  str_camp_t[7]         := 'Hell #6: Космодром';

  str_camp_o[0]         := '-Уничтожь все людские базы и армии'+tc_nl3+'-Защити портал';
  str_camp_o[1]         := '-Уничтожь военную базу';
  str_camp_o[2]         := '-Уничтожь все людские базы и армии'+tc_nl3+'-Защити портал';
  str_camp_o[3]         := '-Защити алтари в течении 20 минут';
  str_camp_o[4]         := '-Уничтожь все людские базы и армии';
  str_camp_o[5]         := '-Уничтожь все людские базы и армии';
  str_camp_o[6]         := '-Уничтожь все людские базы и армии';
  str_camp_o[7]         := '-Уничтожь космодром'+tc_nl3+'-Ни один людской транспорт не должен'+tc_nl3+'уйти';

  str_camp_m[0]         := tc_lime+'Дата:'+tc_default+tc_nl2+'15.11.2145'+tc_nl2+tc_lime+'Место:'+tc_default+tc_nl2+'ФОБОС' +tc_nl2+tc_lime+'Район:'+tc_default+tc_nl2+'Аномалия';
  str_camp_m[1]         := tc_lime+'Дата:'+tc_default+tc_nl2+'16.11.2145'+tc_nl2+tc_lime+'Место:'+tc_default+tc_nl2+'ФОБОС' +tc_nl2+tc_lime+'Район:'+tc_default+tc_nl2+'Кратер Халл';
  str_camp_m[2]         := tc_lime+'Дата:'+tc_default+tc_nl2+'15.11.2145'+tc_nl2+tc_lime+'Место:'+tc_default+tc_nl2+'ДЕЙМОС'+tc_nl2+tc_lime+'Район:'+tc_default+tc_nl2+'Аномалия';
  str_camp_m[3]         := tc_lime+'Дата:'+tc_default+tc_nl2+'16.11.2145'+tc_nl2+tc_lime+'Место:'+tc_default+tc_nl2+'ДЕЙМОС'+tc_nl2+tc_lime+'Район:'+tc_default+tc_nl2+'Кратер Свифт';
  str_camp_m[4]         := tc_lime+'Дата:'+tc_default+tc_nl2+'18.11.2145'+tc_nl2+tc_lime+'Место:'+tc_default+tc_nl2+'МАРС'  +tc_nl2+tc_lime+'Район:'+tc_default+tc_nl2+'Равнина Хеллас';
  str_camp_m[5]         := tc_lime+'Дата:'+tc_default+tc_nl2+'19.11.2145'+tc_nl2+tc_lime+'Место:'+tc_default+tc_nl2+'МАРС'  +tc_nl2+tc_lime+'Район:'+tc_default+tc_nl2+'Равнина Хеллас';
  str_camp_m[6]         := tc_lime+'Дата:'+tc_default+tc_nl2+'18.11.2145'+tc_nl2+tc_lime+'Место:'+tc_default+tc_nl2+'ЗЕМЛЯ' +tc_nl2+tc_lime+'Район:'+tc_default+tc_nl2+'Неизвестно';
  str_camp_m[7]         := tc_lime+'Дата:'+tc_default+tc_nl2+'19.11.2145'+tc_nl2+tc_lime+'Место:'+tc_default+tc_nl2+'ЗЕМЛЯ' +tc_nl2+tc_lime+'Район:'+tc_default+tc_nl2+'Неизвестно';  }

  _makeHints;
end;


procedure SwitchLanguage;
begin
  if(ui_language)
  then lng_rus
  else lng_eng;
end;



