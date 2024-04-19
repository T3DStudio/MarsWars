
function RemoveSpecChars(str:shortstring):shortstring;
var i:byte;
begin
   RemoveSpecChars:=str;
   i:=1;
   while(i<=length(RemoveSpecChars)) do
   begin
      // 10 13
      if(RemoveSpecChars[i]=tc_nl1)
      then RemoveSpecChars[i]:=#10
      else
        if(RemoveSpecChars[i] in [#14..#25])then
        begin
           delete(RemoveSpecChars,i,1);
           i-=1;
        end;
      i+=1;
      if(i=255)then break;
   end;
end;

function _i2s(i:integer):shortstring;
begin
  if(i<0)
  then _i2s:=    i2s(i)
  else _i2s:='+'+i2s(i);
end;

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
    if(_hotkeyO[ucl]>0)then
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
   with g_uids[uid] do
   begin
      un_txt_name  :=NAME;
      un_txt_udescr:=DESCR;
   end;
end;

procedure _mkHStrUpid(upid:byte;NAME,DESCR:shortstring);
begin
   with g_upids[upid] do
   begin
      _up_name :=NAME;
      _up_descr:=DESCR;
      if(length(_up_descr)>0)then
       if(_up_descr[length(_up_descr)]<>'.')then _up_descr+='.';
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
      if(uid in g_uids[i].ups_units  )then _ADDSTR(@up,g_uids[i].un_txt_name,sep_comma);
      if(uid in g_uids[i].ups_builder)then _ADDSTR(@bp,g_uids[i].un_txt_name,sep_comma);
   end;

   if(length(up)>0)then _ADDSTR(@findprd,up,sep_comma);
   if(length(bp)>0)then _ADDSTR(@findprd,bp,sep_comma);
end;


function _makeAttributeStr(pu:PTUnit;auid:byte):shortstring;
begin
   if(pu=nil)then
   begin
      pu:=@g_units[0];
      with pu^ do
      begin
         uidi:=auid;
         playeri:=0;
         player :=@g_players[playeri];
         unit_apllyUID(pu);
         hits:=-32000;
      end;
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

      if(hits>fdead_hits)then
       if(hits>0)
       then _ADDSTR(@_makeAttributeStr,str_attr_alive    ,sep_comma)
       else _ADDSTR(@_makeAttributeStr,str_attr_dead     ,sep_comma);

      if(_ukbuilding)
      then _ADDSTR(@_makeAttributeStr,str_attr_building  ,sep_comma)
      else _ADDSTR(@_makeAttributeStr,str_attr_unit      ,sep_comma);
      if(_ukmech)
      then _ADDSTR(@_makeAttributeStr,str_attr_mech      ,sep_comma)
      else _ADDSTR(@_makeAttributeStr,str_attr_bio       ,sep_comma);
      if(_uklight)
      then _ADDSTR(@_makeAttributeStr,str_attr_light     ,sep_comma)
      else _ADDSTR(@_makeAttributeStr,str_attr_heavy     ,sep_comma);
      if(ukfly)
      then _ADDSTR(@_makeAttributeStr,str_attr_fly       ,sep_comma)
      else
        if(ukfloater)
        then _ADDSTR(@_makeAttributeStr,str_attr_floater,sep_comma)
        else _ADDSTR(@_makeAttributeStr,str_attr_ground ,sep_comma);
      if(transportM>0)
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

      _makeAttributeStr:='['+_makeAttributeStr+tc_default+']';
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

   CheckFlags(wtr_hits_d,wtr_hits_a+
                         wtr_hits_h  ,@str_attr_dead  ,@str_attr_alive   ,false);
   CheckFlags(wtr_unit  ,wtr_building,@str_attr_unit  ,@str_attr_building,false);
   CheckFlags(wtr_bio   ,wtr_mech    ,@str_attr_bio   ,@str_attr_mech    ,false);
   CheckFlags(wtr_light ,wtr_heavy   ,@str_attr_light ,@str_attr_heavy   ,false);
   CheckFlags(wtr_ground,wtr_fly     ,@str_attr_ground,@str_attr_fly     ,false);

   if(length(BaseFlags2Str)=0)then
   CheckFlags(wtr_ground,wtr_fly     ,@str_attr_ground,@str_attr_fly     ,true );

   if(length(BaseFlags2Str)>0)then BaseFlags2Str:='['+BaseFlags2Str+tc_default+']';
end;


function DamageStr(dmod:byte):shortstring;
var i:byte;
begin
   DamageStr:='';
   if(dmod=dm_BFG)
   then DamageStr:='x '+str_TargetLimit
   else
    for i:=0 to MaxDamageModFactors do
     with g_dmods[dmod][i] do
      if(dm_factor<>100)and(dm_flags>0)then
       _ADDSTR(@DamageStr,'x'+l2s(dm_factor,100)+' '+BaseFlags2Str(dm_flags),sep_comma);
end;

function _req2s(basename:shortstring;reqn:byte):shortstring;
begin
   _req2s:=basename;
   if(reqn>1)then _req2s+='(x'+b2s(reqn)+')';
end;

function AddReq(ruid,rupid,rupidl:byte):shortstring;
begin
  AddReq:='';
  if(ruid >0)then _ADDSTR(@AddReq,'"'+_req2s(g_uids [ruid ].un_txt_name,1     )+'"' ,sep_comma);
  if(rupid>0)then _ADDSTR(@AddReq,'"'+_req2s(g_upids[rupid]._up_name   ,rupidl)+'"' ,sep_comma);
  if(length(AddReq)>0)then AddReq:='{'+tc_yellow+str_req+tc_default+AddReq+'}';
end;

function _MakeDefaultDescription(uid:byte;basedesc:shortstring;for_doc:boolean):shortstring;
function RebuildStr(uid,uidl:byte):shortstring;
begin
  if(uidl=0)
  then RebuildStr:='"'+g_uids[uid].un_txt_name+'"'
  else RebuildStr:='"'+g_uids[uid].un_txt_name+'['+str_attr_level+b2s(uidl+1)+']"';
end;
begin
   _MakeDefaultDescription:=basedesc;
    with g_uids[uid] do
    begin
       if(not for_doc)then
       _ADDSTR(@_MakeDefaultDescription,str_hits+i2s(_mhits),sep_sdot);
       //_ADDSTR(@_MakeDefaultDescription,str_srange+i2s(_srange),sep_sdot);

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
       begin
          if(_ability=uab_RebuildInPoint)and(_rebuild_uid>0)
          then _ADDSTR(@_MakeDefaultDescription,str_ability+str_transformation+RebuildStr(_rebuild_uid,_rebuild_level)+AddReq(_rebuild_ruid,_rebuild_rupgr,_rebuild_rupgrl),sep_sdot)
          else
            if(length(str_ability_name[_ability])>0)
            then _ADDSTR(@_MakeDefaultDescription,str_ability+'"'+str_ability_name[_ability]+'"'+AddReq(_ability_ruid,_ability_rupgr,_ability_rupgrl),sep_sdot);
       end
       else
         if(_transportM>0)then _ADDSTR(@_MakeDefaultDescription,str_ability+'"'+str_ability_unload+'"',sep_sdot);

       if(_splashresist)then _ADDSTR(@_MakeDefaultDescription,str_splashresist,sep_sdot);

       if(length(_MakeDefaultDescription)>0)then _MakeDefaultDescription+='.';
    end;
end;

function WeaponTargets(tflags:cardinal;tset:TSoB):shortstring;
var u:byte;
  inset:TSoB;
  innum:byte;
  exset:TSoB;
  exnum:byte;
  instr,
  exstr:shortstring;
begin
  WeaponTargets:='';
  instr:='';
  exstr:='';
   if(tset<>uids_all     )then
    if(tset=uids_arch_res)
    then instr:='['+str_attr_dead+tc_default+','+str_demons+'] '+str_except+' ['+g_uids[UID_Cyberdemon].un_txt_name+','
                                                                                +g_uids[UID_Mastermind].un_txt_name+','
                                                                                +g_uids[UID_ArchVile  ].un_txt_name+']'
    else
    begin
      inset:=[];
      innum:=0;
      exset:=[];
      exnum:=0;

      for u:=1 to 255 do
       if(u in tset)then
       begin
          inset+=[u];
          innum+=1;
       end
       else
       begin
          exset+=[u];
          exnum+=1;
       end;

      if(innum<3)then
      begin
         for u:=1 to 255 do
          if(u in inset)then
           _ADDSTR(@instr,g_uids[u].un_txt_name,sep_comma);
         if(length(instr)>0)then instr:='['+instr+']';
      end;
      if(exnum<3)then
      begin
         for u:=1 to 255 do
          if(u in exset)then
           _ADDSTR(@exstr,g_uids[u].un_txt_name,sep_comma);
         if(length(exstr)>0)then exstr:=str_except+' ['+exstr+']';
      end;
   end;

   if(length(instr)>0)
   then WeaponTargets:=instr
   else
     if(length(exstr)>0)
     then WeaponTargets:=BaseFlags2Str(tflags)+' '+exstr
     else WeaponTargets:=BaseFlags2Str(tflags);
end;

function _MakeWeaponDPS(uid,wid:byte):shortstring;
var BaseDmg,
    ocount : integer;
    i,n    : byte;
    sps    : single;
begin
  _MakeWeaponDPS:='';
  with g_uids[uid] do
  with _a_weap[wid] do
  begin
     BaseDmg:=0;
     ocount :=0;
     case aw_type of
     wpt_suicide   : if(_death_missile>0)then
                     begin
                        BaseDmg:=g_mids[_death_missile].mid_base_damage;
                        ocount:=1;
                     end
                     else exit;       //wpt_suicide
     wpt_missle    : begin
                     BaseDmg:=g_mids[aw_oid].mid_base_damage;
                     if(aw_count>=0)
                     then ocount:=aw_count
                     else ocount:=2;
                     end;
     wpt_directdmg,
     wpt_directdmgZ,
     wpt_heal      : BaseDmg:=aw_count;
     end;
     if(aw_type<>wpt_suicide)then
     begin
        n:=0;
        for i:=0 to aw_reload do
          if(i in aw_rld_s)then n+=1;
     end
     else n:=1;

     if(BaseDmg>0)then
     begin
        if(aw_type=wpt_heal)
        then _ADDSTR(@_MakeWeaponDPS,tc_lime+i2s(BaseDmg)+tc_default,'')
        else _ADDSTR(@_MakeWeaponDPS,tc_red +i2s(BaseDmg)+tc_default,'');

        if(ocount>1)
        then _MakeWeaponDPS+='x'+i2s(ocount);
     end;

     if(aw_type=wpt_suicide)
     then sps:=1
     else
       if(aw_fakeshots>0)
       then sps:=(fr_fps1*n/aw_reload)/aw_fakeshots
       else sps:=(fr_fps1*n/aw_reload);
     _ADDSTR(@_MakeWeaponDPS,'*'+Float2Str(sps),'');
  end;
end;

function _MakeWeaponString(uid,wid:byte;docSTR:boolean):shortstring;
const tab : array[false..true] of shortstring = ('-','- ');
var
dmod_str:shortstring;
begin
  with g_uids[uid] do
   with _a_weap[wid] do
   begin
      _MakeWeaponString:='';
      case aw_type of
      0             : exit;
      wpt_missle,
      wpt_directdmg,
      wpt_directdmgZ: if(aw_max_range<0)
                      then _ADDSTR(@_MakeWeaponString,tab[docSTR]+str_weapon_melee    ,sep_scomma)
                      else _ADDSTR(@_MakeWeaponString,tab[docSTR]+str_weapon_ranged   ,sep_scomma);
      wpt_resurect  :      _ADDSTR(@_MakeWeaponString,tab[docSTR]+str_weapon_ressurect,sep_scomma);
      wpt_heal      :      _ADDSTR(@_MakeWeaponString,tab[docSTR]+str_weapon_heal     ,sep_scomma);
      wpt_unit      :      _ADDSTR(@_MakeWeaponString,tab[docSTR]+str_weapon_spawn+' "'+g_uids[aw_oid].un_txt_name+'"',sep_scomma);
      wpt_suicide   :      _ADDSTR(@_MakeWeaponString,tab[docSTR]+str_weapon_suicide  ,sep_scomma);
      end;

      if(docSTR)then
      begin
         if(aw_min_range>0)then
         _ADDSTR(@_MakeWeaponString,'min. range: '+i2s(aw_min_range),sep_scomma);

         if(aw_max_range=aw_srange)then
         begin
            _ADDSTR(@_MakeWeaponString,'max. range: vision range',sep_scomma);
            if(_a_BonusAntiFlyRange     <>0)then _ADDSTR(@_MakeWeaponString,'bonus anti-fly range: '     +_i2s(_a_BonusAntiFlyRange     ),sep_scomma);
            if(_a_BonusAntiGroundRange  <>0)then _ADDSTR(@_MakeWeaponString,'bonus anti-ground range: '  +_i2s(_a_BonusAntiFlyRange     ),sep_scomma);
            if(_a_BonusAntiUnitRange    <>0)then _ADDSTR(@_MakeWeaponString,'bonus anti-unit range: '    +_i2s(_a_BonusAntiUnitRange    ),sep_scomma);
            if(_a_BonusAntiBuildingRange<>0)then _ADDSTR(@_MakeWeaponString,'bonus anti-building range: '+_i2s(_a_BonusAntiBuildingRange),sep_scomma);
         end
         else
           if(aw_max_range<aw_srange) // melee
           then //_ADDSTR(@_MakeWeaponString,'max range: melee',sep_scomma)
           else
             if(aw_max_range>=aw_fsr0)then  // relative srange
             begin
                if(aw_max_range<>aw_fsr)
                then _ADDSTR(@_MakeWeaponString,'max. range: vision range'+_i2s(aw_max_range-aw_fsr),sep_scomma)
                else _ADDSTR(@_MakeWeaponString,'max. range: vision range',sep_scomma);
             end
             else
             begin
                _ADDSTR(@_MakeWeaponString,'max. range: '+i2s(aw_max_range),sep_scomma);  // absolute
                if(_a_BonusAntiFlyRange   <>0)then _ADDSTR(@_MakeWeaponString,'bonus anti-fly range: '   +_i2s(_a_BonusAntiFlyRange),sep_scomma);
                if(_a_BonusAntiGroundRange<>0)then _ADDSTR(@_MakeWeaponString,'bonus anti-ground range: '+_i2s(_a_BonusAntiFlyRange),sep_scomma);
             end;
      end;

      if(aw_type=wpt_directdmgZ)then
      _ADDSTR(@_MakeWeaponString,str_weapon_zombie,sep_scomma);

      _ADDSTR(@_MakeWeaponString,str_weapon_targets+WeaponTargets(aw_tarf,aw_uids),sep_scomma);

      _ADDSTR(@_MakeWeaponString,str_weapon_damage+' '+_MakeWeaponDPS(uid,wid),sep_scomma);
      if(docSTR)then
      begin
         if(aw_type=wpt_missle)then
          with g_mids[aw_oid] do
           if(mid_base_splashr>0)then  _ADDSTR(@_MakeWeaponString,'splash damage radius: '+i2s(mid_base_splashr),sep_scomma);

         if(aw_type=wpt_suicide)and(_death_missile>0)then
          with g_mids[_death_missile] do
           if(mid_base_splashr>0)then  _ADDSTR(@_MakeWeaponString,'splash damage radius: '+i2s(mid_base_splashr),sep_scomma);

         if(aw_dupgr>0)then
           _ADDSTR(@_MakeWeaponString,'upgrade: '+g_upids[aw_dupgr]._up_name+'('+_i2s(aw_dupgr_s)+')',sep_scomma);
      end;

      dmod_str:='';

      case aw_type of
      wpt_suicide   : if(_death_missile>0)then dmod_str:=DamageStr(_death_missile_dmod);
      wpt_missle,
      wpt_directdmg,
      wpt_directdmgZ: if(aw_dmod>0)then dmod_str:=DamageStr(aw_dmod);
      end;

      if(length(dmod_str)>0)then
        if(docSTR)
        then _ADDSTR(@_MakeWeaponString,dmod_str,', factor: ')
        else _ADDSTR(@_MakeWeaponString,dmod_str,': '      );

      _ADDSTR(@_MakeWeaponString,AddReq(aw_ruid,aw_rupgr,aw_rupgr_l),sep_scomma);

      if(docSTR)then _MakeWeaponString:=RemoveSpecChars(_MakeWeaponString);
   end;
end;

function _MakeWeaponsDescription(uid:byte;docSTR:boolean):shortstring;
var w:byte;
weapons_str:shortstring;
begin
  _MakeWeaponsDescription:='';
  with g_uids[uid] do
  begin
     weapons_str:='';
     if(_attack=atm_always)then
      for w:=0 to MaxUnitWeapons do
       with _a_weap[w] do
        _ADDSTR(@weapons_str,_MakeWeaponString(uid,w,docSTR),sep_sdots);

     if(length(weapons_str)>0)then
      if(docSTR)
      then _ADDSTR(@_MakeWeaponsDescription,weapons_str,sep_sdot)
      else _ADDSTR(@_MakeWeaponsDescription,str_UnitArming+weapons_str,sep_sdot);
  end;
  if(length(_MakeWeaponsDescription)>0)then _MakeWeaponsDescription+='.';
end;

function _makeUpgrBaseHint(upid,curlvl:byte):shortstring;
var HK,
    ENRG,
    TIME,
    INFO:shortstring;
    i   :byte;
begin
  with g_upids[upid] do
  begin
     HK  :=_gHK(_up_btni);
     ENRG:='';
     TIME:='';
     INFO:='';

     if(_up_max<=1)or(_up_mfrg)
     then curlvl:=1
     else
       if(curlvl>_up_max)and(curlvl<255)then curlvl:=_up_max;

     HK:=_gHK(_up_btni);
     if(_up_renerg>0)then
       if(curlvl<255)
       then ENRG:=tc_aqua +i2s(_upid_energy(upid,curlvl))+tc_default
       else
         if(_up_max>0)then
         begin
            for i:=1 to _up_max do _ADDSTR(@ENRG,i2s(_upid_energy(upid,i)),'/');
            ENRG:=tc_aqua+ENRG+tc_default;
         end;
     if(_up_time  >0)then
       if(curlvl<255)
       then TIME:=tc_white+i2s(_upid_time(upid,curlvl)div fr_fps1)+tc_default
       else
         if(_up_max>0)then
         begin
            for i:=1 to _up_max do _ADDSTR(@TIME,i2s(_upid_time(upid,i)div fr_fps1),'/');
            TIME:=tc_white+TIME+tc_default;
         end;
     if(length(HK  )>0)then _ADDSTR(@INFO,HK  ,sep_comma);
     if(length(ENRG)>0)then _ADDSTR(@INFO,ENRG,sep_comma);
     if(length(TIME)>0)then _ADDSTR(@INFO,TIME,sep_comma);
     _ADDSTR(@INFO,tc_orange+'x'+i2s(_up_max)+tc_default,sep_comma);
     if(_up_max>1)and(_up_mfrg)then _ADDSTR(@INFO,tc_red+'*'+tc_default,sep_comma);

     _makeUpgrBaseHint:=_up_name+' ('+INFO+')'+tc_nl1+tc_nl1+_up_descr;
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
   with g_uids[uid] do
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
         if(_ruid1>0)then _ADDSTR(@REQ,_req2s(g_uids [_ruid1].un_txt_name,_ruid1n),sep_comma);
         if(_ruid2>0)then _ADDSTR(@REQ,_req2s(g_uids [_ruid2].un_txt_name,_ruid2n),sep_comma);
         if(_ruid3>0)then _ADDSTR(@REQ,_req2s(g_uids [_ruid3].un_txt_name,_ruid3n),sep_comma);
         if(_rupgr>0)then _ADDSTR(@REQ,_req2s(g_upids[_rupgr]._up_name   ,_rupgrl),sep_comma);

         if(length(HK  )>0)then _ADDSTR(@INFO,HK  ,sep_comma);
         if(length(ENRG)>0)then _ADDSTR(@INFO,ENRG,sep_comma);
         if(length(LMT )>0)then _ADDSTR(@INFO,LMT ,sep_comma);
         if(length(TIME)>0)then _ADDSTR(@INFO,TIME,sep_comma);

         un_txt_fdescr :=_MakeDefaultDescription(uid,un_txt_udescr,false);

         un_txt_uihint1:=un_txt_name+' ('+INFO+')'+tc_nl1+_makeAttributeStr(nil,uid);
         un_txt_uihintS:=un_txt_name+tc_nl1;
         un_txt_uihint2:=un_txt_fdescr;
         un_txt_uihint3:=_MakeWeaponsDescription(uid,false);
         un_txt_uihint4:='';

         if(length(REQ )>0)then un_txt_uihint4+=tc_yellow+str_requirements+tc_default+REQ+tc_nl1
                           else un_txt_uihint4+=tc_nl1;
         if(length(PROD)>0)then
          if(_ukbuilding)
          then un_txt_uihint4+=str_bprod+PROD
          else un_txt_uihint4+=str_uprod+PROD;
      end;
   end;

   // upgrades
   for uid:=0 to 255 do
   with g_upids[uid] do
   begin
      REQ  :='';

      if(_up_ruid1 >0)then _ADDSTR(@REQ,g_uids [_up_ruid1].un_txt_name,sep_comma);
      if(_up_ruid2 >0)then _ADDSTR(@REQ,g_uids [_up_ruid2].un_txt_name,sep_comma);
      if(_up_ruid3 >0)then _ADDSTR(@REQ,g_uids [_up_ruid3].un_txt_name,sep_comma);
      if(_up_rupgr >0)then _ADDSTR(@REQ,g_upids[_up_rupgr]._up_name   ,sep_comma);

      _up_hint:='';
      if(length(REQ)>0)then _up_hint+=tc_yellow+str_requirements+tc_default+REQ;
   end;
end;

procedure lng_eng;
var t: shortstring;
    p: byte;
begin
   str_MMap              := 'MAP';
   str_MPlayers          := 'PLAYERS';
   str_MObjectives       := 'OBJECTIVES';
   str_MServers          := 'SERVERS';
   str_menu_s1[ms1_sett] := 'SETTINGS';
   str_menu_s1[ms1_svld] := 'SAVE/LOAD';
   str_menu_s1[ms1_reps] := 'REPLAYS';
   str_menu_s2[ms2_camp] := 'CAMPAIGNS';
   str_menu_s2[ms2_game] := 'GAME';
   str_menu_s2[ms2_mult] := 'MULTIPLAYER';
   str_menu_s3[ms3_game] := 'GAME';
   str_menu_s3[ms3_vido] := 'VIDEO';
   str_menu_s3[ms3_sond] := 'SOUND';
   str_reset[false]      := 'START';
   str_reset[true ]      := 'RESET';
   str_exit[false]       := 'EXIT';
   str_exit[true]        := 'BACK';
   str_m_tpe             := 'Type: ';
   str_mapt[mapt_steppe] := tc_gray  +'Steppe';
   str_mapt[mapt_nature] := tc_green +'Mountains';
   str_mapt[mapt_lake  ] := tc_yellow+'Lake';
   str_mapt[mapt_shore ] := tc_orange+'Sea shore';
   str_mapt[mapt_sea   ] := tc_red   +'Sea';
   str_m_siz             := 'Size: ';
   str_m_sym             := 'Symm.: ';
   str_m_symt[0]         := 'no';
   str_m_symt[1]         := 'point';
   str_m_symt[2]         := 'line';
   str_map               := 'Map';
   str_players           := 'Players';
   str_mrandom           := 'Random map';
   str_musicvol          := 'Music volume';
   str_soundvol          := 'Sound volume';
   str_scrollspd         := 'Scroll speed';
   str_mousescrl         := 'Mouse scroll';
   str_fullscreen        := 'Windowed';
   str_plname            := 'Player name';
   str_lng[true]         := 'RUS';
   str_lng[false]        := 'ENG';
   str_maction           := 'Right-click action';
   str_maction2[true ]   := tc_lime  +'move'  +tc_default;
   str_maction2[false]   := tc_lime  +'move'  +tc_default+'+'+tc_red+'attack'+tc_default;
   str_race[r_random]    := tc_default+'RANDOM';
   str_race[r_hell  ]    := tc_orange+'HELL'  +tc_default;
   str_race[r_uac   ]    := tc_lime  +'UAC'   +tc_default;
   str_observer          := 'OBSERV.';
   str_win               := 'VICTORY!';
   str_lose              := 'DEFEAT!';
   str_gsunknown         := 'Unknown status!';
   str_pause             := 'Pause';
   str_gsaved            := 'Game saved';
   str_repend            := 'Replay ended!';
   str_reperror          := 'Read file error!';
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
   str_replay_status     := 'STATUS';
   str_replay_name       := 'Replay name';
   str_cmpdif            := 'Difficulty ';
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
   str_aislots           := 'Fill empty slots';
   str_resol_width       := 'Resolution (width)';
   str_resol_height      := 'Resolution (height)';
   str_language          := 'UI language';
   str_requirements      := 'Requirements: ';
   str_req               := 'Req.: ';
   str_orders            := 'Unit groups: ';
   str_all               := 'All';
   str_uprod             := tc_lime+'Produced by: '   +tc_default;
   str_bprod             := tc_lime+'Constructed by: '+tc_default;
   str_ColoredShadow     := 'Colored shadows';
   str_kothtime          := 'Center capture time left: ';
   str_kothtime_act      := 'Time left until center area is active: ';
   str_kothwinner        := ' is King of the Hill!';
   str_DeadObservers     := 'Observer mode after lose';
   str_FPS               := 'Show FPS';
   str_APM               := 'Show APM';
   str_ability           := 'Special ability: ';
   str_transformation    := 'transformation into ';
   str_upgradeslvl       := 'Upgrades: ';
   str_demons            := 'demons&zombies';
   str_except            := 'except';
   str_splashresist      := 'Immune to splash damage';
   str_TargetLimit       := 'target limit';
   str_NextTrack         := 'Play next track';
   str_PlayerPaused      := 'player paused the game';
   str_PlayerResumed     := 'player has resumed the game';

   str_builder           := 'Builder';
   str_barrack           := 'Unit production';
   str_smith             := 'Researches and upgrades facility';
   str_IncEnergyLevel    := 'Increases energy level';
   str_CanRebuildTo      := 'Can be rebuilt into ';
   str_UnitArming        := 'Arming/Abilities: ';
   str_hits              := 'Hits: ';
   str_srange            := 'Base sight range: ';

   str_weapon_melee      := 'melee attack';
   str_weapon_ranged     := 'ranged attack';
   str_weapon_zombie     := '+zombification';
   str_weapon_ressurect  := 'resurrection';
   str_weapon_heal       := 'heal/repair';
   str_weapon_spawn      := 'spawn';
   str_weapon_suicide    := 'suicide';
   str_weapon_targets    := 'targets: ';
   str_weapon_damage     := 'impact';

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
   str_mapMark           := ' set a mark on the map';

   str_attr_alive        := tc_lime  +'alive'       ;
   str_attr_dead         := tc_dgray +'dead'        ;
   str_attr_unit         := tc_gray  +'unit'        ;
   str_attr_building     := tc_red   +'building'    ;
   str_attr_mech         := tc_blue  +'mechanical'  ;
   str_attr_bio          := tc_orange+'biological'  ;
   str_attr_light        := tc_yellow+'light'       ;
   str_attr_heavy        := tc_green +'heavy'       ;
   str_attr_fly          := tc_white +'flying'      ;
   str_attr_ground       := tc_lime  +'ground'      ;
   str_attr_floater      := tc_aqua  +'floater'     ;
   str_attr_level        := tc_white +'level'       ;
   str_attr_invuln       := tc_lime  +'invulnerable';
   str_attr_stuned       := tc_yellow+'stuned'      ;
   str_attr_detector     := tc_purple+'detector'    ;
   str_attr_transport    := tc_gray  +'transport'   ;

   str_PlayerSlots[ps_closed  ]:='closed';
   str_PlayerSlots[ps_observer]:='observer';
   str_PlayerSlots[ps_opened  ]:='opened';
   str_PlayerSlots[ps_replace ]:='jump here';
   str_PlayerSlots[ps_AI_1    ]:='AI 1';
   str_PlayerSlots[ps_AI_2    ]:='AI 2';
   str_PlayerSlots[ps_AI_3    ]:='AI 3';
   str_PlayerSlots[ps_AI_4    ]:='AI 4';
   str_PlayerSlots[ps_AI_5    ]:='AI 5';
   str_PlayerSlots[ps_AI_6    ]:='AI 6';
   str_PlayerSlots[ps_AI_7    ]:='AI 7';
   str_PlayerSlots[ps_AI_8    ]:='AI cheater 1';
   str_PlayerSlots[ps_AI_9    ]:='AI cheater 2';
   str_PlayerSlots[ps_AI_10   ]:='AI cheater 3';
   str_PlayerSlots[ps_AI_11   ]:='AI cheater 4';
   {
   ps_replace             = 3;  // menu option, not state
   ps_AI_1                = 4;  // very easy
   ps_AI_2                = 5;  // easy
   ps_AI_3                = 6;  // medium
   ps_AI_4                = 7;  // hard
   ps_AI_5                = 8;  // harder
   ps_AI_6                = 9;  // very hard
   ps_AI_7                = 10; // elite
   ps_AI_8                = 11; // Cheater 1 (Vision)
   ps_AI_9                = 12; // Cheater 2 (Vision+MultiProd)
   ps_AI_10               = 13; // Cheater 3 (Vision+MultiProd+FastUProd)
   ps_AI_11               = 14; // Cheater 4 (Vision+MultiProd+FastUProd+FastBProd)
   }

   str_teams[0]          := str_observer;
   for p:=1 to MaxPlayers do
   str_teams[p]          := 'team '+b2s(p);

   str_panelpos          := 'Control panel position';
   str_panelposp[0]      := tc_lime  +'left'  +tc_default;
   str_panelposp[1]      := tc_orange+'right' +tc_default;
   str_panelposp[2]      := tc_yellow+'top'   +tc_default;
   str_panelposp[3]      := tc_aqua  +'bottom'+tc_default;

   str_uhbar             := 'Health bars';
   str_uhbars[0]         := tc_lime  +'selected'+tc_default+'+'+tc_red+'damaged'+tc_default;
   str_uhbars[1]         := tc_aqua  +'always'  +tc_default;
   str_uhbars[2]         := tc_orange+'only '   +tc_lime+'selected'+tc_default;

   str_pcolor            := 'Players color';
   str_pcolors[0]        := tc_white +'default'+tc_default;
   str_pcolors[1]        := tc_lime  +'own '   +tc_yellow+'ally '+tc_red+'enemy'+tc_default;
   str_pcolors[2]        := tc_white +'own '   +tc_yellow+'ally '+tc_red+'enemy'+tc_default;
   str_pcolors[3]        := tc_white +'own '   +tc_aqua  +'ally '+tc_red+'enemy'+tc_default;
   str_pcolors[4]        := tc_purple+'teams'  +tc_default;
   str_pcolors[5]        := tc_white +'own '   +tc_purple+'teams'+tc_default;

   str_starta            := 'Builders at the game start';

   str_fstarts           := 'Fixed player starts';

   str_pnua[0]           := tc_aqua  +'x1 '+tc_default+'/'+tc_red   +' x1';
   str_pnua[1]           := tc_aqua  +'x2 '+tc_default+'/'+tc_red   +' x2';
   str_pnua[2]           := tc_lime  +'x3 '+tc_default+'/'+tc_orange+' x3';
   str_pnua[3]           := tc_lime  +'x4 '+tc_default+'/'+tc_orange+' x4';
   str_pnua[4]           := tc_yellow+'x5 '+tc_default+'/'+tc_yellow+' x5';
   str_pnua[5]           := tc_yellow+'x6 '+tc_default+'/'+tc_yellow+' x6';
   str_pnua[6]           := tc_orange+'x7 '+tc_default+'/'+tc_lime  +' x7';
   str_pnua[7]           := tc_orange+'x8 '+tc_default+'/'+tc_lime  +' x8';
   str_pnua[8]           := tc_red   +'x9 '+tc_default+'/'+tc_aqua  +' x9';
   str_pnua[9]           := tc_red   +'x10'+tc_default+'/'+tc_aqua  +' x10';

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

   str_gmodet            := 'Game mode';
   str_gmode[gm_scirmish]:= tc_lime  +'Skirmish'        +tc_default;
   str_gmode[gm_3x3     ]:= tc_orange+'3x3'             +tc_default;
   str_gmode[gm_2x2x2   ]:= tc_yellow+'2x2x2'           +tc_default;
   str_gmode[gm_capture ]:= tc_aqua  +'Capturing points'+tc_default;
   str_gmode[gm_invasion]:= tc_blue  +'Invasion'        +tc_default;
   str_gmode[gm_KotH    ]:= tc_purple+'King of the Hill'+tc_default;
   str_gmode[gm_royale  ]:= tc_red   +'Battle Royal'    +tc_default;

   str_generators        := 'Generators';
   str_generatorsO[0]    := 'own';
   str_generatorsO[1]    := 'own,no new builders';
   str_generatorsO[2]    := 'neutral(5 min)';
   str_generatorsO[3]    := 'neutral(10 min)';
   str_generatorsO[4]    := 'neutral(15 min)';
   str_generatorsO[5]    := 'neutral(20 min)';
   str_generatorsO[6]    := 'neutral(infinity)';

   str_rstatus[rpls_state_none ]:=           'OFF';
   str_rstatus[rpls_state_write]:= tc_yellow+'RECORD';
   str_rstatus[rpls_state_read ]:= tc_lime  +'PLAY';

   str_team              := 'Team:';
   str_srace             := 'Race:';
   str_ready             := 'Ready: ';
   str_udpport           := 'UDP port';
   str_svup[false]       := 'Start server';
   str_svup[true ]       := 'Stop server';
   str_connect[false]    := 'Connect';
   str_connect[true ]    := 'Disconnect';
   str_pnu               := 'File size/quality ';
   str_npnu              := 'Units update rate ';
   str_connecting        := 'Connecting...';
   str_netsearching      := 'Searching for servers...';
   str_netsearch         := 'Search for LAN servers';
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
   str_ability_unload                    :='Unload';

   _mkHStrUid(UID_HKeep          ,'Hell Keep'                   ,'');
   _mkHStrUid(UID_HAKeep         ,'Great Hell Keep'             ,'');
   _mkHStrUid(UID_HGate          ,'Demon`s Gate'                ,'');
   _mkHStrUid(UID_HSymbol        ,'Unholy Symbol'               ,'');
   _mkHStrUid(UID_HASymbol       ,'Great Unholy Symbol'         ,'');
   _mkHStrUid(UID_HPools         ,'Infernal Pools'              ,'');
   _mkHStrUid(UID_HTeleport      ,'Teleporter'                  ,'');
   _mkHStrUid(UID_HPentagram     ,'Pentagram of Death'          ,'');
   _mkHStrUid(UID_HMonastery     ,'Monastery of Despair'        ,'');
   _mkHStrUid(UID_HFortress      ,'Castle of the Damned'        ,'');
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
   _mkHStrUid(UID_Mastermind     ,'Spider Mastermind'           ,'');
   _mkHStrUid(UID_Pain           ,'Pain Elemental'              ,'');
   _mkHStrUid(UID_Revenant       ,'Revenant'                    ,'');
   _mkHStrUid(UID_Mancubus       ,'Mancubus'                    ,'');
   _mkHStrUid(UID_Arachnotron    ,'Arachnotron'                 ,'');
   _mkHStrUid(UID_Archvile       ,'Arch-Vile'                   ,'');
   _mkHStrUid(UID_ZFormer        ,'Former Zombie'               ,'');
   _mkHStrUid(UID_ZEngineer      ,'Zombie Engineer'             ,'');
   _mkHStrUid(UID_ZSergant       ,'Zombie Shotgunner'           ,'');
   _mkHStrUid(UID_ZSSergant      ,'Zombie SuperShotgunner'      ,'');
   _mkHStrUid(UID_ZCommando      ,'Zombie Commando'             ,'');
   _mkHStrUid(UID_ZAntiaircrafter,'Anti-aircraft Zombie'        ,'');
   _mkHStrUid(UID_ZSiegeMarine   ,'Zombie Siege Marine'         ,'');
   _mkHStrUid(UID_ZFPlasmagunner ,'Zombie Plasmagunner'         ,'');
   _mkHStrUid(UID_ZBFGMarine     ,'Zombie BFG Marine'           ,'');


   _mkHStrUpid(upgr_hell_t1attack  ,'Hell Firepower'                ,'Increase the damage of ranged attacks for T1 units and defensive structures');
   _mkHStrUpid(upgr_hell_uarmor    ,'Combat Flesh'                  ,'Increase the armor of all Hell units'                                   );
   _mkHStrUpid(upgr_hell_barmor    ,'Stone Walls'                   ,'Increase the armor of all Hell buildings'                               );
   _mkHStrUpid(upgr_hell_mattack   ,'Claws and Teeth'               ,'Increase the damage of melee attacks'                                   );
   _mkHStrUpid(upgr_hell_regen     ,'Flesh Regeneration'            ,'Health regeneration for all Hell units'                                 );
   _mkHStrUpid(upgr_hell_pains     ,'Pain Threshold'                ,'Hell units can take more hits before being stunned by pain'             );
   _mkHStrUpid(upgr_hell_towers    ,'Demonic Spirits'               ,'Increase the range of defensive structures'                             );
   _mkHStrUpid(upgr_hell_HKTeleport,'Hell Keep Blink Charge'        ,'Charge for the Hell Keep`s ability'                                     );
   _mkHStrUpid(upgr_hell_paina     ,'Decay Aura'                    ,'Hell Keep damages all nearby enemy units. Decay Aura damage ignores unit armor.');
   _mkHStrUpid(upgr_hell_buildr    ,'Hell Keep Range Upgrade'       ,'Increase the Hell Keep`s range of vision'                               );
   _mkHStrUpid(upgr_hell_extbuild  ,'Adaptive Foundation'           ,'All buildings, except the Teleporter and unit-producing structures, can be placed on doodads.');
   _mkHStrUpid(upgr_hell_ghostm    ,'Ghost Monsters'                ,'Pinky Demons can move over obstacles'                           );

   _mkHStrUpid(upgr_hell_spectre   ,'Specters'                      ,'Pinky Demons become invisible'                                  );
   _mkHStrUpid(upgr_hell_vision    ,'Hell Sight'                    ,'Increase the sight range of all Hell units'                     );
   _mkHStrUpid(upgr_hell_phantoms  ,'Phantoms'                      ,'Pain Elemental spawns Phantoms instead of Lost Souls'            );
   _mkHStrUpid(upgr_hell_t2attack  ,'Demonic Weapons'               ,'Increase the damage of ranged attacks for T2 units and defensive structures'  );
   _mkHStrUpid(upgr_hell_teleport  ,'Teleporter Upgrade'            ,'Reduced cooldown on Teleporter ability'                         );
   _mkHStrUpid(upgr_hell_rteleport ,'Reverse Teleportation'         ,'Units can teleport back to Teleporter'                          );
   _mkHStrUpid(upgr_hell_heye      ,'Evil Eye Upgrade'              ,'Increase the sight range of Evil Eye'                           );
   _mkHStrUpid(upgr_hell_totminv   ,'Totem of Horror Invisibility'  ,'Totem of Horror becomes invisible'                              );
   _mkHStrUpid(upgr_hell_bldrep    ,'Building Restoration'          ,'Health regeneration for all Hell buildings'                     );
   _mkHStrUpid(upgr_hell_tblink    ,'Tower Teleportation Charge'    ,'Charges for the ability of Guard Tower and Totem of Horror');
   _mkHStrUpid(upgr_hell_resurrect ,'Resurrection'                  ,'ArchVile`s ability'                    );
   _mkHStrUpid(upgr_hell_invuln    ,'Invulnerability Sphere'        ,'Charge for the Altar of Pain ability'      );


   _mkHStrUid(UID_UCommandCenter   ,'Command Center'                ,''      );
   _mkHStrUid(UID_UACommandCenter  ,'Advanced Command Center'       ,''      );
   _mkHStrUid(UID_UBarracks        ,'Barracks'                      ,''      );
   _mkHStrUid(UID_UFactory         ,'Vehicle Factory'               ,''      );
   _mkHStrUid(UID_UGenerator       ,'Generator'                     ,''      );
   _mkHStrUid(UID_UAGenerator      ,'Advanced Generator'            ,''      );
   _mkHStrUid(UID_UWeaponFactory   ,'Weapons Factory'               ,''      );
   _mkHStrUid(UID_UGTurret         ,'Anti-ground Turret'            ,'Anti-ground defensive structure');
   _mkHStrUid(UID_UATurret         ,'Anti-air Turret'               ,'Anti-air defensive structure'   );
   _mkHStrUid(UID_UTechCenter      ,'Science Facility'              ,'');
   _mkHStrUid(UID_UComputerStation ,'Computer Station'              ,'');
   _mkHStrUid(UID_URadar           ,'Radar'                         ,'Reveals map');
   _mkHStrUid(UID_URMStation       ,'Rocket Launcher Station'       ,'');
   _mkHStrUid(UID_UMine            ,'Mine'                          ,'');

   _mkHStrUid(UID_Sergant          ,'Shotguner'                     ,'');
   _mkHStrUid(UID_SSergant         ,'SuperShotguner'                ,'');
   _mkHStrUid(UID_Commando         ,'Commando'                      ,'');
   _mkHStrUid(UID_Antiaircrafter   ,'Anti-aircraft Marine'          ,'');
   _mkHStrUid(UID_SiegeMarine      ,'Siege Marine'                  ,'');
   _mkHStrUid(UID_FPlasmagunner    ,'Plasmagunner'                  ,'');
   _mkHStrUid(UID_BFGMarine        ,'BFG Marine'                    ,'');
   _mkHStrUid(UID_Engineer         ,'Engineer'                      ,'');
   _mkHStrUid(UID_Medic            ,'Medic'                         ,'');
   _mkHStrUid(UID_UTransport       ,'Dropship'                      ,'');
   _mkHStrUid(UID_UACDron          ,'Drone'                         ,'');
   _mkHStrUid(UID_Terminator       ,'Terminator'                    ,'');
   _mkHStrUid(UID_Tank             ,'Tank'                          ,'');
   _mkHStrUid(UID_Flyer            ,'Fighter'                       ,'');
   _mkHStrUid(UID_APC              ,'Ground APC'                    ,'');


   _mkHStrUpid(upgr_uac_attack     ,'Weapons Upgrade'                  ,'Increase the damage of ranged attacks for all UAC units and defensive structures');
   _mkHStrUpid(upgr_uac_uarmor     ,'Infantry Combat Armor Upgrade'    ,'Increase the armor of all Barracks-produced units'             );
   _mkHStrUpid(upgr_uac_barmor     ,'Concrete Walls'                   ,'Increase the armor of all UAC buildings'                       );
   _mkHStrUpid(upgr_uac_melee      ,'Advanced Tools'                   ,'Increase repair/healing efficiency of Engineers/Medics'        );
   _mkHStrUpid(upgr_uac_mspeed     ,'Lightweight Armor'                ,'Increase the movement speed of all Barracks-produced units'            );
   _mkHStrUpid(upgr_uac_ssgup      ,'Expansive bullets'                ,'Shotgunner, SuperShotgunner and Terminator deal more damage to ['+str_attr_bio+']' );
   _mkHStrUpid(upgr_uac_towers     ,'Spotlights'                       ,'Increase the range of defensive structures'                    );
   _mkHStrUpid(upgr_uac_CCFly      ,'Command Center Flight Engines'    ,'Command Center gains ability to fly'                           );
   _mkHStrUpid(upgr_uac_ccturr     ,'Command Center Turret'            ,'Plasma turret for Command Center'                              );
   _mkHStrUpid(upgr_uac_buildr     ,'Command Center Range Upgrade'     ,'Increase Command Center`s range of vision'                           );
   _mkHStrUpid(upgr_uac_extbuild   ,'Adaptive Foundation'              ,'All buildings, except those that can produce units, can be placed on doodads');
   _mkHStrUpid(upgr_uac_soaring    ,'Antigravity Platform'             ,'Drones can move over obstacles'              );

   _mkHStrUpid(upgr_uac_botturret  ,'Drone Transformation Protocol'    ,'A Drone can rebuild to Anti-ground turret'    );
   _mkHStrUpid(upgr_uac_vision     ,'Light Amplification Visors'       ,'Increase the sight range of all UAC units'  );
   _mkHStrUpid(upgr_uac_commando   ,'Stealth Technology'               ,'Commando becomes invisible'                 );
   _mkHStrUpid(upgr_uac_airsp      ,'Fragmentation Missiles'           ,'Anti-air missiles do extra damage around the target'  );
   _mkHStrUpid(upgr_uac_mechspd    ,'Advanced Engines'                 ,'Increase the movement speed of all Factory-produced units'      );
   _mkHStrUpid(upgr_uac_mecharm    ,'Mech Combat Armor Upgrade'        ,'Increase the armor of all Factory-produced units'               );
   _mkHStrUpid(upgr_uac_lturret    ,'Fighter Laser Gun'                ,'Fighter anti-ground weapon'                              );
   _mkHStrUpid(upgr_uac_transport  ,'Dropship Upgrade'                 ,'Increase the capacity of the Dropship'                   );
   _mkHStrUpid(upgr_uac_radar_r    ,'Radar Upgrade'                    ,'Increase radar scanning radius'             );
   _mkHStrUpid(upgr_uac_plasmt     ,'Anti-ground Plasmagun'            ,'Anti-['+str_attr_mech+'] weapon for Anti-ground turret'           );
   _mkHStrUpid(upgr_uac_turarm     ,'Additional Armoring'              ,'Additional armor for Turrets'               );
   _mkHStrUpid(upgr_uac_rstrike    ,'Rocket Strike Charge'             ,'Charge for Rocket Launcher Station ability' );


   _mkHStrACT(0 ,'Specail ability');
   t:='Specail ability at point';
   _mkHStrACT(1 ,t);
   str_NeedpsabilityOrder:= 'Use "'+t+'" order!';
   _mkHStrACT(2 ,'Rebuild/Upgrade');
   t:='attack enemies';
   _mkHStrACT(3 ,'Move, '  +t);
   _mkHStrACT(4 ,'Stop, '  +t);
   _mkHStrACT(5 ,'Patrol, '+t);
   t:='ignore enemies';
   _mkHStrACT(6 ,'Move, '  +t);
   _mkHStrACT(7 ,'Stop, '  +t);
   _mkHStrACT(8 ,'Patrol, '+t);
   _mkHStrACT(9 ,'Cancel production');
   _mkHStrACT(10,'Select all battle units' );
   _mkHStrACT(11,'Destroy'          );
   _mkHStrACT(12,'Alarm mark'       );
   _mkHStrACT(13,str_maction);

   _mkHStrRPL(0 ,'Faster game speed'    ,false);
   _mkHStrRPL(1 ,'Left click: back 2 seconds ('                                +tc_lime+'W'+tc_default+')'+tc_nl1+
                 'Right click: back 10 seconds ('+tc_lime+'Ctrl'+tc_default+'+'+tc_lime+'W'+tc_default+')'+tc_nl1+
                 'Middle click: back 1 minute (' +tc_lime+'Alt' +tc_default+'+'+tc_lime+'W'+tc_default+')',true);
   _mkHStrRPL(2 ,'Left click: skip 2 seconds ('                                +tc_lime+'E'+tc_default+')'+tc_nl1+
                 'Right click: skip 10 seconds ('+tc_lime+'Ctrl'+tc_default+'+'+tc_lime+'E'+tc_default+')'+tc_nl1+
                 'Middle click: skip 1 minute (' +tc_lime+'Alt' +tc_default+'+'+tc_lime+'E'+tc_default+')',true);
   _mkHStrRPL(3 ,'Pause'                ,false);
   _mkHStrRPL(4 ,'Player-recorder POV'  ,false);
   _mkHStrRPL(5 ,'List of game messages',false);
   _mkHStrRPL(6 ,'Fog of war'           ,false);
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
    p: byte;
begin
  str_MMap              := '�����';
  str_MPlayers          := '������';
  str_MObjectives       := '������';
  str_MServers          := '�������';
  str_menu_s1[ms1_sett] := '���������';
  str_menu_s1[ms1_svld] := '����./����.';
  str_menu_s1[ms1_reps] := '������';
  str_menu_s2[ms2_camp] := '��������';
  str_menu_s2[ms2_game] := '����';
  str_menu_s2[ms2_mult] := '������� ����';
  str_menu_s3[ms3_game] := '����';
  str_menu_s3[ms3_vido] := '�������';
  str_menu_s3[ms3_sond] := '����';
  str_reset[false]      := '������';
  str_reset[true ]      := '�����';
  str_exit[false]       := '�����';
  str_exit[true]        := '�����';
  str_m_tpe             := '���: ';
  str_mapt[mapt_steppe] := tc_gray  +'�����';
  str_mapt[mapt_nature] := tc_green +'����';
  str_mapt[mapt_lake  ] := tc_yellow+'�����';
  str_mapt[mapt_shore ] := tc_orange+'����� ����';
  str_mapt[mapt_sea   ] := tc_red   +'����';
  str_m_siz             := '������: ';
  str_m_sym             := '����.: ';
  str_m_symt[0]         := '���';
  str_m_symt[1]         := '�����';
  str_m_symt[2]         := '�����';
  str_map               := '�����';
  str_players           := '������';
  str_mrandom           := '��������� �����';
  str_musicvol          := '��������� ������';
  str_soundvol          := '��������� ������';
  str_scrollspd         := '�������� ��.';
  str_mousescrl         := '�����. �����';
  str_fullscreen        := '� ����';
  str_plname            := '��� ������';
  str_maction           := '�������� �� ������ ����';
  str_maction2[true ]   := tc_lime+'��������'+tc_default;
  str_maction2[false]   := tc_lime+'����.'   +tc_default+'+'+tc_red+'�����'+tc_default;
  str_race[r_random]    := tc_default+'�����';
  str_observer          := '�������';
  str_pause             := '�����';
  str_win               := '������!';
  str_lose              := '���������!';
  str_gsunknown         := '����������� ������!';
  str_gsaved            := '���� ���������';
  str_repend            := '����� ������!';
  str_reperror          := '������ ��� ������ �����!';
  str_save              := '���������';
  str_load              := '���������';
  str_delete            := '�������';
  str_svld_errors_file  := '���� ��'+tc_nl3+'����������!';
  str_svld_errors_open  := '������������'+tc_nl3+'������� ����!';
  str_svld_errors_wdata := '������������'+tc_nl3+'������ �����!';
  str_svld_errors_wver  := '������������'+tc_nl3+'������ �����!';
  str_time              := '�����: ';
  str_menu              := '����';
  str_player_def        := ' ���������!';
  str_inv_time          := '����� #';
  str_inv_ml            := '����� ��������: ';
  str_play              := '���������';
  str_replay            := '������';
  str_replay_status     := '������';
  str_replay_name       := '�������� ������';
  str_cmpdif            := '���������: ';
  str_waitsv            := '�������� �������...';
  str_goptions          := '��������� ����';
  str_server            := '������';
  str_client            := '������';
  str_menu_chat         := '���(��� ������)';
  str_chat_all          := '���:';
  str_chat_allies       := '��������:';
  str_randoms           := '��������� �������';
  str_apply             := '���������';
  str_plout             := ' ������� ����';
  str_aislots           := '��������� ������ �����';
  str_resol_width       := '���������� (������)';
  str_resol_height      := '���������� (������)';
  str_language          := '���� ����������';
  str_requirements      := '����������: ';
  str_req               := '����.: ';
  str_orders            := '������: ';
  str_all               := '���';
  str_uprod             := tc_lime+'��������� �: '+tc_default;
  str_bprod             := tc_lime+'��� ����� ���� ��������: '     +tc_default;
  str_ColoredShadow     := '������� ����';
  str_kothtime          := '����� �� ������� ������: ';
  str_kothtime_act      := '����� �� ��������� ����������� ����: ';
  str_kothwinner        := ' - ���� ����!';
  str_DeadObservers     := '����������� ����� ���������';
  str_FPS               := '�������� FPS';
  str_APM               := '�������� APM';
  str_ability           := '����������� �����������: ';
  str_transformation    := '����������� � ';
  str_upgradeslvl       := '���������: ';
  str_demons            := '������ � �����';
  str_except            := '�����';
  str_splashresist      := '������������� � �������� �����';
  str_TargetLimit       := '����� ����';
  str_NextTrack         := '��������� ����';
  str_PlayerPaused      := '����� ������������ ����';
  str_PlayerResumed     := '����� ���������� ����';

  str_builder           := '���������';
  str_barrack           := '���������� ������';
  str_smith             := '��������� ��������� � ��������';
  str_IncEnergyLevel    := '����������� ������� �������';
  str_CanRebuildTo      := '����� ����������� � ';
  str_UnitArming        := '����������/�����������: ';
  str_hits              := '��������: ';
  str_srange            := '������� ������ ������: ';

  str_weapon_melee      := '������� ���';
  str_weapon_ranged     := '������� ���';
  str_weapon_zombie     := '+������������';
  str_weapon_ressurect  := '�����������';
  str_weapon_heal       := '�������/������';
  str_weapon_spawn      := '����������';
  str_weapon_suicide    := '������������';
  str_weapon_targets    := '����: ';
  str_weapon_damage     := '�����������';

  str_cant_build        := '������ ������� �����';
  str_need_energy       := '���������� ������ �������';
  str_cant_prod         := '��������� ���������� ���';
  str_check_reqs        := '��������� ����������';
  str_cant_execute      := '����������� ��������� ������';
  str_advanced          := '���������� ';
  str_unit_advanced     := '���� �������';
  str_upgrade_complete  := '������������ ���������';
  str_building_complete := '��������� ���������';
  str_unit_complete     := '���� �����';
  str_unit_attacked     := '���� ��������';
  str_base_attacked     := '���� ���������';
  str_allies_attacked   := '���� �������� ���������';
  str_maxlimit_reached  := '��������� ������������ ������ �����';
  str_need_more_builders:= '���������� ������ ����������';
  str_production_busy   := '��� ������������ ������';
  str_cant_advanced     := '���������� �����������/��������';
  str_NeedMoreProd      := '����� ����������� ���';
  str_MaximumReached    := '��������� ��������';
  str_mapMark           := ' �������� ������� �� �����';

  str_attr_alive        := tc_lime  +'�����'         ;
  str_attr_dead         := tc_dgray +'�������'       ;
  str_attr_unit         := tc_gray  +'����'          ;
  str_attr_building     := tc_red   +'������'        ;
  str_attr_mech         := tc_blue  +'������������'  ;
  str_attr_bio          := tc_orange+'�������������' ;
  str_attr_light        := tc_yellow+'������'        ;
  str_attr_heavy        := tc_green +'�������'       ;
  str_attr_fly          := tc_white +'��������'      ;
  str_attr_ground       := tc_lime  +'��������'      ;
  str_attr_floater      := tc_aqua  +'�������'       ;
  str_attr_level        := tc_white +'������� '      ;
  str_attr_invuln       := tc_lime  +'����������'    ;
  str_attr_stuned       := tc_yellow+'�������'       ;
  str_attr_detector     := tc_purple+'��������'      ;
  str_attr_transport    := tc_gray  +'���������'     ;

  str_PlayerSlots[ps_closed  ]:='�������';
  str_PlayerSlots[ps_observer]:='�������';
  str_PlayerSlots[ps_opened  ]:='�������';
  str_PlayerSlots[ps_replace ]:='�� ���� ����';
  str_PlayerSlots[ps_AI_1    ]:='�� 1';
  str_PlayerSlots[ps_AI_2    ]:='�� 2';
  str_PlayerSlots[ps_AI_3    ]:='�� 3';
  str_PlayerSlots[ps_AI_4    ]:='�� 4';
  str_PlayerSlots[ps_AI_5    ]:='�� 5';
  str_PlayerSlots[ps_AI_6    ]:='�� 6';
  str_PlayerSlots[ps_AI_7    ]:='�� 7';
  str_PlayerSlots[ps_AI_8    ]:='�� ����� 1';
  str_PlayerSlots[ps_AI_9    ]:='�� ����� 2';
  str_PlayerSlots[ps_AI_10   ]:='�� ����� 3';
  str_PlayerSlots[ps_AI_11   ]:='�� ����� 4';
  {
  ps_replace             = 3;  // menu option, not state
  ps_AI_1                = 4;  // very easy
  ps_AI_2                = 5;  // easy
  ps_AI_3                = 6;  // medium
  ps_AI_4                = 7;  // hard
  ps_AI_5                = 8;  // harder
  ps_AI_6                = 9;  // very hard
  ps_AI_7                = 10; // elite
  ps_AI_8                = 11; // Cheater 1 (Vision)
  ps_AI_9                = 12; // Cheater 2 (Vision+MultiProd)
  ps_AI_10               = 13; // Cheater 3 (Vision+MultiProd+FastUProd)
  ps_AI_11               = 14; // Cheater 4 (Vision+MultiProd+FastUProd+FastBProd)
  }

  str_teams[0]          := str_observer;
  for p:=1 to MaxPlayers do
  str_teams[p]          := '���. '+b2s(p);

  str_panelpos          := '��������� ������� ������';
  str_panelposp[0]      := tc_lime  +'�����' +tc_default;
  str_panelposp[1]      := tc_orange+'������'+tc_default;
  str_panelposp[2]      := tc_yellow+'������'+tc_default;
  str_panelposp[3]      := tc_aqua  +'�����' +tc_default;

  str_uhbar             := '������� ��������';
  str_uhbars[0]         := tc_lime  +'���������'+tc_default+'+'+tc_red+'�������.'+tc_default;
  str_uhbars[1]         := tc_aqua  +'������'   +tc_default;
  str_uhbars[2]         := tc_orange+'������ '  +tc_lime+'���������'+tc_default;

  str_pcolor            := '����� �������';
  str_pcolors[0]        := tc_white +'�� ���������'+tc_default;
  str_pcolors[1]        := tc_lime  +'���� '+tc_yellow+'�������� '+tc_red+'�����'+tc_default;
  str_pcolors[2]        := tc_white +'���� '+tc_yellow+'�������� '+tc_red+'�����'+tc_default;
  str_pcolors[3]        := tc_purple+'�������'+tc_default;
  str_pcolors[4]        := tc_white +'���� '+tc_purple+'�������'+tc_default;

  str_starta            := '���������� ���������� �� ������';

  str_fstarts           := '������������� ������';

  str_gmodet            := '����� ����';
  str_gmode[gm_scirmish]:= tc_lime  +'�������'           +tc_default;
  str_gmode[gm_3x3     ]:= tc_orange+'3x3'               +tc_default;
  str_gmode[gm_2x2x2   ]:= tc_yellow+'2x2x2'             +tc_default;
  str_gmode[gm_capture ]:= tc_aqua  +'������ �����'      +tc_default;
  str_gmode[gm_invasion]:= tc_blue  +'���������'         +tc_default;
  str_gmode[gm_KotH    ]:= tc_purple+'���� ����'         +tc_default;
  str_gmode[gm_royale  ]:= tc_red   +'����������� �����' +tc_default;

  str_generators        := '����������';
  str_generatorsO[0]    := '����';
  str_generatorsO[1]    := '����,��� ����� ������.';
  str_generatorsO[2]    := '���������.(5 ���.)';
  str_generatorsO[3]    := '���������.(10 ���.)';
  str_generatorsO[4]    := '���������.(15 ���.)';
  str_generatorsO[5]    := '���������.(20 ���.)';
  str_generatorsO[6]    := '���������.(������.)';

  str_rstatus[rpls_state_none ]:=           '����.';
  str_rstatus[rpls_state_write]:= tc_yellow+'������';
  str_rstatus[rpls_state_read ]:= tc_lime  +'���������������';

  str_team              := '����:';
  str_srace             := '����:';
  str_ready             := '�����: ';
  str_udpport           := 'UDP ����:';
  str_svup[false]       := '�������� ������';
  str_svup[true ]       := '��������� ������';
  str_connect[false]    := '�����������';
  str_connect[true ]    := '����������';
  str_pnu               := '������/��������: ';
  str_npnu              := '���������� ������: ';
  str_connecting        := '����������...';
  str_netsearching      := '����� ��������...';
  str_netsearch         := '����� �������� � ��������� ����';
  str_sver              := '������ ������!';
  str_sfull             := '��� ����!';
  str_sgst              := '���� ��������!';

  str_hint_t[0]         := '������';
  str_hint_t[1]         := '�����';
  str_hint_t[2]         := '������������';
  str_hint_t[3]         := '������';

  str_hint_m[0]         := '���� (' +tc_lime+'Esc'        +tc_default+')';
  str_hint_m[2]         := '����� ('+tc_lime+'Pause/Break'+tc_default+')';

  str_hint_army         := '�����: ';
  str_hint_energy       := '�������: ';

  str_ability_name[uab_Teleport        ]:='������������';
  str_ability_name[uab_UACScan         ]:='������������';
  str_ability_name[uab_HTowerBlink     ]:='������';
  str_ability_name[uab_UACStrike       ]:='�������� ����';
  str_ability_name[uab_HKeepBlink      ]:='�����������';
  str_ability_name[uab_RebuildInPoint  ]:='';
  str_ability_name[uab_HInvulnerability]:='������������';
  str_ability_name[uab_SpawnLost       ]:='��������� Lost Soul';
  str_ability_name[uab_HellVision      ]:='������ ������';
  str_ability_name[uab_CCFly           ]:='��������� ��� ������';
  str_ability_unload                    :='���������';

  _mkHStrUid(UID_HKeep           ,'������ ��������'            ,'');
  _mkHStrUid(UID_HAKeep          ,'������� ������ ��������'    ,'');
  _mkHStrUid(UID_HGate           ,'����� �������'              ,'');
  _mkHStrUid(UID_HSymbol         ,'���������� ������'          ,'');
  _mkHStrUid(UID_HASymbol        ,'������� ���������� ������'  ,'');
  _mkHStrUid(UID_HPools          ,'������������ �����'         ,'');
  _mkHStrUid(UID_HTeleport       ,'��������'                   ,'');
  _mkHStrUid(UID_HPentagram      ,'����������� ������'         ,'');
  _mkHStrUid(UID_HMonastery      ,'��������� ��������'         ,'');
  _mkHStrUid(UID_HFortress       ,'����� ���������'            ,'');
  _mkHStrUid(UID_HTower          ,'���������� �����'           ,'�������� ����������'                  );
  _mkHStrUid(UID_HTotem          ,'����� �����'                ,'����������� �������� ����������'      );
  _mkHStrUid(UID_HAltar          ,'������ ����'                ,'');
  _mkHStrUid(UID_HCommandCenter  ,'��������� ��������� �����'  ,''          );
  _mkHStrUid(UID_HACommandCenter ,'����������� ��������� ��������� �����','');
  _mkHStrUid(UID_HBarracks       ,'������� �����'              ,''          );
  _mkHStrUid(UID_HEye            ,'��� ���'                    ,''          );

  _mkHStrUid(UID_ZFormer         ,'������� �����'              ,'');
  _mkHStrUid(UID_ZEngineer       ,'����� �������'              ,'');
  _mkHStrUid(UID_ZSergant        ,'����� �������'              ,'');
  _mkHStrUid(UID_ZSSergant       ,'����� ������� �������'      ,'');
  _mkHStrUid(UID_ZCommando       ,'����� ��������'             ,'');
  _mkHStrUid(UID_ZAntiaircrafter ,'����� ��������'             ,'');
  _mkHStrUid(UID_ZSiegeMarine    ,'����� �����������'          ,'');
  _mkHStrUid(UID_ZFPlasmagunner  ,'����� ������������'         ,'');
  _mkHStrUid(UID_ZBFGMarine      ,'����� ������ � BFG'         ,'');

  _mkHStrUpid(upgr_hell_t1attack  ,'������ ������� ����'           ,'���������� ����� �� ������� ���� ���� �1 ������ � �������� ����������');
  _mkHStrUpid(upgr_hell_uarmor    ,'������ �����'                  ,'���������� ������ ���� ������ ������'                                 );
  _mkHStrUpid(upgr_hell_barmor    ,'�������� �����'                ,'���������� ������ ���� ������ ������'                                 );
  _mkHStrUpid(upgr_hell_mattack   ,'����� � ����'                  ,'���������� ����� �� ������� ����'                                     );
  _mkHStrUpid(upgr_hell_regen     ,'����������� �����'             ,'�������������� �������� ���� ������ ������'                           );
  _mkHStrUpid(upgr_hell_pains     ,'������� �����'                 ,'������ ����� ���� ���������� ������� �������'                         );
  _mkHStrUpid(upgr_hell_towers    ,'������������ ��������'         ,'���������� ������� ������ � ����� ��� �������� ����������'            );
  _mkHStrUpid(upgr_hell_HKTeleport,'������������ ������ ��������'  ,'����� ��� ����������� ������ ��������'                                );
  _mkHStrUpid(upgr_hell_paina     ,'���� ����������'               ,'������ �������� ������� ���� ���� ��������� ��-������� ������. ���� ���������� ����� ������');
  _mkHStrUpid(upgr_hell_buildr    ,'���������� ������� ������ ������ ��������',''                                       );
  _mkHStrUpid(upgr_hell_extbuild  ,'���������� ���������'          ,'��� ������, ����� ��������� � ������������ ������ ����� ������� �� ����������');
  _mkHStrUpid(upgr_hell_ghostm    ,'���������� �������'            ,'Pinky Demon ����� ������ �� ����������'                                       );

  _mkHStrUpid(upgr_hell_spectre   ,'��������'                      ,'Pinky Demon ����������� ���������'                                         );
  _mkHStrUpid(upgr_hell_vision    ,'������ ������'                 ,'���������� ������� ������ � ����� ���� ������ ������'                      );
  _mkHStrUpid(upgr_hell_phantoms  ,'�������'                       ,'Pain Elemental ������� �������� ������ Lost Soul'                          );
  _mkHStrUpid(upgr_hell_t2attack  ,'������������ ������'           ,'���������� ����� �� ������� ���� ���� �2 ������ � �������� ����������'     );
  _mkHStrUpid(upgr_hell_teleport  ,'��������� ���������'           ,'���������� ������� ����������� ���������'                              );
  _mkHStrUpid(upgr_hell_rteleport ,'�������� ������������'         ,'������ ����� ���������� ������� � ��������'                            );
  _mkHStrUpid(upgr_hell_heye      ,'��������� ��� ���'             ,'���������� ������� ������ ��� ���'                           );
  _mkHStrUpid(upgr_hell_totminv   ,'����������� ������ �����'      ,''                               );
  _mkHStrUpid(upgr_hell_bldrep    ,'�������������� ������'         ,'�������������� �������� ���� ������ ������'                   );
  _mkHStrUpid(upgr_hell_tblink    ,'�������� ������������'         ,'������ ��� ����������� ������ ����� � ������ �����');
  _mkHStrUpid(upgr_hell_resurrect ,'�����������'                   ,'����������� ArchVile'                    );
  _mkHStrUpid(upgr_hell_invuln    ,'����� ������������'            ,'������ ��� ����������� ������ ����'      );


  _mkHStrUid(UID_UCommandCenter  ,'��������� �����'            ,'');
  _mkHStrUid(UID_UACommandCenter ,'����������� ��������� �����','');
  _mkHStrUid(UID_UBarracks       ,'�������'                    ,'');
  _mkHStrUid(UID_UFactory        ,'�������'                    ,'');
  _mkHStrUid(UID_UGenerator      ,'���������'                  ,'');
  _mkHStrUid(UID_UAGenerator     ,'����������� ���������'      ,'');
  _mkHStrUid(UID_UWeaponFactory  ,'����� ����������'           ,'');
  _mkHStrUid(UID_UGTurret        ,'����-�������� ������'       ,'����-�������� �������� ����������' );
  _mkHStrUid(UID_UATurret        ,'����-��������� ������'      ,'����-��������� �������� ����������');
  _mkHStrUid(UID_UTechCenter     ,'������� �����'              ,'');
  _mkHStrUid(UID_UComputerStation,'������������ �������'       ,'');
  _mkHStrUid(UID_URadar          ,'�����'                      ,'��������� �����');
  _mkHStrUid(UID_URMStation      ,'������� ��������� �����'    ,'');
  _mkHStrUid(UID_UMine           ,'����'                       ,'');

  _mkHStrUid(UID_Sergant         ,'�������'                ,'');
  _mkHStrUid(UID_SSergant        ,'������� �������'        ,'');
  _mkHStrUid(UID_Commando        ,'��������'               ,'');
  _mkHStrUid(UID_Antiaircrafter  ,'��������'               ,'');
  _mkHStrUid(UID_SiegeMarine     ,'�����������'            ,'');
  _mkHStrUid(UID_FPlasmagunner   ,'������������'           ,'');
  _mkHStrUid(UID_BFGMarine       ,'������ � BFG'           ,'');
  _mkHStrUid(UID_Engineer        ,'�������'                ,'');
  _mkHStrUid(UID_Medic           ,'�����'                  ,'');
  _mkHStrUid(UID_UACDron         ,'����'                   ,'');
  _mkHStrUid(UID_UTransport      ,'��������� �������'      ,'');
  _mkHStrUid(UID_Terminator      ,'����������'             ,'');
  _mkHStrUid(UID_Tank            ,'����'                   ,'');
  _mkHStrUid(UID_Flyer           ,'�����������'            ,'');
  _mkHStrUid(UID_APC             ,'���'                    ,'');


  _mkHStrUpid(upgr_uac_attack     ,'��������� ���������'               ,'���������� ����� �� ������� ���� ���� ������ � �������� ����������');
  _mkHStrUpid(upgr_uac_uarmor     ,'��������� �������� �����'          ,'���������� ������ ���� ������ �� ������'                     );
  _mkHStrUpid(upgr_uac_barmor     ,'�������� �����'                    ,'���������� ������ ���� ������'                               );
  _mkHStrUpid(upgr_uac_melee      ,'����������� �����������'           ,'���������� ������������� ������� �������� � ������� ������'  );
  _mkHStrUpid(upgr_uac_mspeed     ,'����������� �����'                 ,'���������� �������� ������������ ���� ������ �� ������'      );
  _mkHStrUpid(upgr_uac_ssgup      ,'��������� ����'                    ,'�������, ������� ������� � ���������� ������� ������ ����� �� ['+str_attr_bio+'].' );
  _mkHStrUpid(upgr_uac_towers     ,'����������'                        ,'���������� ������� ������ � ����� ��� �������� ����������'      );
  _mkHStrUpid(upgr_uac_CCFly      ,'������ ��������� ���������� ������','��������� ����� ����� ������'                                  );
  _mkHStrUpid(upgr_uac_ccturr     ,'������ ���������� ������'          ,'��������� ����� ����� ���������'                                );
  _mkHStrUpid(upgr_uac_buildr     ,'���������� ������� ������ ���������� ������',''                           );
  _mkHStrUpid(upgr_uac_extbuild   ,'���������� ���������'              ,'��� ������, ����� ������������ ������ ����� ������� �� ����������');
  _mkHStrUpid(upgr_uac_soaring    ,'������������������ ���������'      ,'���� ����� ������������ �� ����������'              );

  _mkHStrUpid(upgr_uac_botturret  ,'�������� ������������� �����'      ,'���� ����� ������������ � ����-�������� ������'    );
  _mkHStrUpid(upgr_uac_vision     ,'���������� ������'                 ,'���������� ������� ������ � ����� ���� ������'  );
  _mkHStrUpid(upgr_uac_commando   ,'�����-����������'                  ,'�������� ����������� ���������'                 );
  _mkHStrUpid(upgr_uac_airsp      ,'���������� �������'                ,'������������� ������� ������� ���� �� �������'  );
  _mkHStrUpid(upgr_uac_mechspd    ,'��������� ���������'               ,'���������� �������� ������������ ������ �� �������'      );
  _mkHStrUpid(upgr_uac_mecharm    ,'��������� ����������� �����'       ,'���������� ������ ���� ������ �� �������'                );
  _mkHStrUpid(upgr_uac_lturret    ,'�������� ������'                   ,'����-�������� ������ ��� �����������'                    );
  _mkHStrUpid(upgr_uac_transport  ,'��������� ����������'              ,'���������� ����������� ���������� �������'               );
  _mkHStrUpid(upgr_uac_radar_r    ,'��������� ������'                  ,'���������� ������� ������ ������'            );
  _mkHStrUpid(upgr_uac_plasmt     ,'����-�������� ���������� ������'   ,'����-['+str_attr_mech+'] ������ ��� ����-�������� ������');
  _mkHStrUpid(upgr_uac_turarm     ,'�������������� ������������'       ,'�������������� ������ ��� �������'              );
  _mkHStrUpid(upgr_uac_rstrike    ,'�������� ����'                     ,'������ ��� ����������� ������� ��������� �����' );


  _mkHStrACT(0 ,'����������� �����������'        );
  t:='����������� ����������� � �����';
  _mkHStrACT(1 ,t);
  str_NeedpsabilityOrder:= '����������� ������ "'+t+'"!';
  _mkHStrACT(2 ,'�����������/��������');
  t:='��������� ������';
  _mkHStrACT(3 ,'���������, '       +t);
  _mkHStrACT(4 ,'������, '          +t);
  _mkHStrACT(5 ,'�������������, '   +t);
  t:='������������ ������';
  _mkHStrACT(6 ,'���������, '       +t);
  _mkHStrACT(7 ,'������, '          +t);
  _mkHStrACT(8 ,'�������������, '   +t);
  _mkHStrACT(9 ,'������ ������������' );
  _mkHStrACT(10,'������� ���� ������ ��������� ������');
  _mkHStrACT(11,'����������'          );
  _mkHStrACT(12,'��������� �����'     );
  _mkHStrACT(13,str_maction           );

  _mkHStrRPL(0 ,'��������/��������� ���������� ��������',false);
  _mkHStrRPL(1 ,'����� ����: ����� �� 2 ������� ('                                 +tc_lime+'W'+tc_default+')'+tc_nl1+
                '������ ����: ����� �� 10 ������ ('  +tc_lime+'Ctrl'+tc_default+'+'+tc_lime+'W'+tc_default+')'+tc_nl1+
                '������� ����: ����� �� 1 ������ ('  +tc_lime+'Alt' +tc_default+'+'+tc_lime+'W'+tc_default+')',true  );
  _mkHStrRPL(2 ,'����� ����: ���������� 2 ������� ('                               +tc_lime+'E'+tc_default+')'+tc_nl1+
                '������ ����: ���������� 10 ������ ('+tc_lime+'Ctrl'+tc_default+'+'+tc_lime+'E'+tc_default+')'+tc_nl1+
                '������� ����: ���������� 1 ������ ('+tc_lime+'Alt' +tc_default+'+'+tc_lime+'E'+tc_default+')',true  );
  _mkHStrRPL(3 ,'�����'                   ,false);
  _mkHStrRPL(4 ,'������ ������'           ,false);
  _mkHStrRPL(5 ,'������ ������� ���������',false);
  _mkHStrRPL(6 ,'����� �����'             ,false);
  _mkHStrRPL(8 ,'��� ������'              ,false);
  _mkHStrRPL(9 ,'����� #1',false);
  _mkHStrRPL(10,'����� #2',false);
  _mkHStrRPL(11,'����� #3',false);
  _mkHStrRPL(12,'����� #4',false);
  _mkHStrRPL(13,'����� #5',false);
  _mkHStrRPL(14,'����� #6',false);

  _mkHStrOBS(0 ,'����� �����',false);
  _mkHStrOBS(2 ,'��� ������' ,false);
  _mkHStrOBS(3 ,'����� #1'   ,false);
  _mkHStrOBS(4 ,'����� #2'   ,false);
  _mkHStrOBS(5 ,'����� #3'   ,false);
  _mkHStrOBS(6 ,'����� #4'   ,false);
  _mkHStrOBS(7 ,'����� #5'   ,false);
  _mkHStrOBS(8 ,'����� #6'   ,false);


  {str_camp_t[0]         := 'Hell #1: ��������� �� �����';
  str_camp_t[1]         := 'Hell #2: ������� ����';
  str_camp_t[2]         := 'Hell #3: ��������� �� ������';
  str_camp_t[3]         := 'Hell #4: ����������� ������';
  str_camp_t[4]         := 'Hell #7: ������';
  str_camp_t[5]         := 'Hell #8: �� �� �����';
  str_camp_t[6]         := 'Hell #5: �� �� �����';
  str_camp_t[7]         := 'Hell #6: ���������';

  str_camp_o[0]         := '-�������� ��� ������� ���� � �����'+tc_nl3+'-������ ������';
  str_camp_o[1]         := '-�������� ������� ����';
  str_camp_o[2]         := '-�������� ��� ������� ���� � �����'+tc_nl3+'-������ ������';
  str_camp_o[3]         := '-������ ������ � ������� 20 �����';
  str_camp_o[4]         := '-�������� ��� ������� ���� � �����';
  str_camp_o[5]         := '-�������� ��� ������� ���� � �����';
  str_camp_o[6]         := '-�������� ��� ������� ���� � �����';
  str_camp_o[7]         := '-�������� ���������'+tc_nl3+'-�� ���� ������� ��������� �� ������'+tc_nl3+'����';

  str_camp_m[0]         := tc_lime+'����:'+tc_default+tc_nl2+'15.11.2145'+tc_nl2+tc_lime+'�����:'+tc_default+tc_nl2+'�����' +tc_nl2+tc_lime+'�����:'+tc_default+tc_nl2+'��������';
  str_camp_m[1]         := tc_lime+'����:'+tc_default+tc_nl2+'16.11.2145'+tc_nl2+tc_lime+'�����:'+tc_default+tc_nl2+'�����' +tc_nl2+tc_lime+'�����:'+tc_default+tc_nl2+'������ ����';
  str_camp_m[2]         := tc_lime+'����:'+tc_default+tc_nl2+'15.11.2145'+tc_nl2+tc_lime+'�����:'+tc_default+tc_nl2+'������'+tc_nl2+tc_lime+'�����:'+tc_default+tc_nl2+'��������';
  str_camp_m[3]         := tc_lime+'����:'+tc_default+tc_nl2+'16.11.2145'+tc_nl2+tc_lime+'�����:'+tc_default+tc_nl2+'������'+tc_nl2+tc_lime+'�����:'+tc_default+tc_nl2+'������ �����';
  str_camp_m[4]         := tc_lime+'����:'+tc_default+tc_nl2+'18.11.2145'+tc_nl2+tc_lime+'�����:'+tc_default+tc_nl2+'����'  +tc_nl2+tc_lime+'�����:'+tc_default+tc_nl2+'������� ������';
  str_camp_m[5]         := tc_lime+'����:'+tc_default+tc_nl2+'19.11.2145'+tc_nl2+tc_lime+'�����:'+tc_default+tc_nl2+'����'  +tc_nl2+tc_lime+'�����:'+tc_default+tc_nl2+'������� ������';
  str_camp_m[6]         := tc_lime+'����:'+tc_default+tc_nl2+'18.11.2145'+tc_nl2+tc_lime+'�����:'+tc_default+tc_nl2+'�����' +tc_nl2+tc_lime+'�����:'+tc_default+tc_nl2+'����������';
  str_camp_m[7]         := tc_lime+'����:'+tc_default+tc_nl2+'19.11.2145'+tc_nl2+tc_lime+'�����:'+tc_default+tc_nl2+'�����' +tc_nl2+tc_lime+'�����:'+tc_default+tc_nl2+'����������';  }

  _makeHints;
end;


procedure WriteUnitDescriptions;
const fname = '_strings.txt';
var f:text;
    u,
    w:byte;
tmp:shortstring;
procedure upgrLine(upid:byte;info:shortstring);
begin
   if(upid>0)then
    with g_upids[upid] do
      writeln(f,'- ',_up_name,' - ',info,';');
end;

begin
   assign(f,fname);
   rewrite(f);

   for u:=0 to 255 do
    with g_uids[u] do
     if(length(un_txt_uihint1)>0)and(_r>0)then
     begin
        writeln(f,un_txt_name);
        writeln(f);

        writeln(f,'Hotkey: ',RemoveSpecChars(_gHK(_ucl)));
        writeln(f,'Categories/Attributes: ',RemoveSpecChars(_makeAttributeStr(nil,u)));
        writeln(f,'Max hits: ',_mhits);
        writeln(f,'Limit used: ', l2s(_limituse,ul1));
        writeln(f,'Size: ',_r);
        if(_speed>0)then
        writeln(f,'Base movement speed: ' , _speed);
        writeln(f,'Base vision range: ', _srange);
        writeln(f,'Build time: ' , _btime);
        writeln(f,'Energy required: ' , _renergy);
        if(_painc>0)then
        writeln(f,'PainState base threshold: ' , _painc);
        if(not _ukfly)and(not _ukbuilding)then
        writeln(f,'Slots in transport: ',_transportS );
        if(_transportM>0)then
        writeln(f,'Base transport capacity: ',_transportM );

        if(_zombie_uid>0)then
        if(_zombie_hits>0)or(_fastdeath_hits<0)then
        begin
        writeln(f,'Zombie variant: ',g_uids[_zombie_uid].un_txt_name );
        writeln(f,'Zombification hits: ',_zombie_hits);
        end;

        writeln(f,RemoveSpecChars(un_txt_uihint4));

        if(_attack=atm_always)then
        begin
           writeln(f,str_UnitArming);
           for w:=0 to MaxUnitWeapons do
            with _a_weap[w] do
            begin
               tmp:=_MakeWeaponString(u,w,true);
               if(length(tmp)>0)then writeln(f,tmp,';');
            end;
        end;


        writeln(f,'Upgrades:');
        upgrLine(_upgr_srange,'vision range '+_i2s(_upgr_srange_step));
        if(not _ukbuilding)then
        upgrLine(upgr_race_unit_srange[_urace],'vision range '+_i2s(upgr_race_srange_unit_bonus[_urace]));

        if(_ukbuilding)
        then upgrLine(_upgr_armor,'armor '+_i2s(BaseArmorBonus2))
        else upgrLine(_upgr_armor,'armor '+_i2s(BaseArmorBonus1));

        if(_ukbuilding)
        then upgrLine(upgr_race_armor_build[_urace],'armor '+_i2s(BaseArmorBonus2))
        else
          if(_ukmech)
          then upgrLine(upgr_race_armor_mech[_urace],'armor '+_i2s(BaseArmorBonus1))
          else upgrLine(upgr_race_armor_bio [_urace],'armor '+_i2s(BaseArmorBonus1));

        upgrLine(_upgr_regen,'hits regeneration '+_i2s(BaseArmorBonus1));
        if(_ukbuilding)
        then upgrLine(upgr_race_regen_build[_urace],'hits regeneration '+_i2s(BaseArmorBonus1))
        else
          if(_ukmech)
          then upgrLine(upgr_race_regen_mech[_urace],'hits regeneration '+_i2s(BaseArmorBonus1))
          else upgrLine(upgr_race_regen_bio [_urace],'hits regeneration '+_i2s(BaseArmorBonus1));

        if(_ukbuilding)
        then
        else
          if(_ukmech)
          then upgrLine(upgr_race_mspeed_mech[_urace],'movement speed '+_i2s(2))
          else upgrLine(upgr_race_mspeed_bio [_urace],'movement speed '+_i2s(2));

        if(not _ukbuilding)and(not _ukmech)and(_painc>0)and(_urace=r_hell)then
        upgrLine(upgr_hell_pains,'PainState threshold '+_i2s(_painc_upgr_step));

        if(_ukbuilding)and(not _isbarrack)and(_ability<>uab_Teleport)then
        upgrLine(upgr_race_extbuilding[_urace],'allows building this structure on doodads');


        writeln(f);

        writeln(f,RemoveSpecChars(_MakeDefaultDescription(u,un_txt_udescr,true)));

        writeln(f);
        {
        Max count	Unlimited
        }
        writeln(f,'---------------------------');
        writeln(f);
     end;

   writeln(f);

   for u:=0 to 255 do
    with g_upids[u] do
     if(length(_up_name)>0)then
     begin
        writeln(f,RemoveSpecChars(_makeUpgrBaseHint(u,255)));
        writeln(f,RemoveSpecChars(_up_hint));
        writeln(f);
     end;
   writeln(f);
{
s1:=_makeUpgrBaseHint(uid,upgr[uid]+1);
hs1:=@s1;
hs4:=@g_upids[uid]._up_hint;
}

   close(f);
end;

procedure SwitchLanguage;
begin
  if(ui_language)
  then lng_rus
  else lng_eng;
end;



