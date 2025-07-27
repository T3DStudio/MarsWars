
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

function i2sSign(i:integer):shortstring;
begin
  if(i<0)
  then i2sSign:=    i2s(i)
  else i2sSign:='+'+i2s(i);
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



function HotKeyBase2Str(ucl:byte):shortstring;  // hotkey units&upgrades tab
begin
   HotKeyBase2Str:='';
   if(ucl<=max_HotKeys)then
    if(HotKeysBase1[ucl]>0)then
    begin
       if(HotKeysBase2[ucl]>0)then
       HotKeyBase2Str:=               tc_lime+GetKeyName(HotKeysBase2[ucl])+tc_default+'+';
       HotKeyBase2Str:=HotKeyBase2Str+tc_lime+GetKeyName(HotKeysBase1[ucl])+tc_default;
    end;
end;
function HotKeyAction2Str(ucl:byte):shortstring;  // hotkey actions tab
begin
   HotKeyAction2Str:='';
   if(ucl<=max_HotKeys)then
    if(HotKeysAction1[ucl]>0)then
    begin
       if(HotKeysAction2[ucl]>0)then
       HotKeyAction2Str:=                 tc_lime+GetKeyName(HotKeysAction2[ucl])+tc_default+'+';
       HotKeyAction2Str:=HotKeyAction2Str+tc_lime+GetKeyName(HotKeysAction1 [ucl])+tc_default;
    end;
end;
function HotKeyReplay2Str(ucl:byte):shortstring;  // hotkey replays tab
begin
   HotKeyReplay2Str:='';
   if(ucl<=max_HotKeys)then
    if(HotKeysReplay[ucl]>0)then
     HotKeyReplay2Str:=tc_lime+GetKeyName(HotKeysReplay [ucl])+tc_default;
end;
function HotKeyObserver2Str(ucl:byte):shortstring;  // hotkey observer tab
begin
   HotKeyObserver2Str:='';
   if(ucl<=max_HotKeys)then
    if(HotKeysObserv[ucl]>0)then
     HotKeyObserver2Str:=tc_lime+GetKeyName(HotKeysObserv [ucl])+tc_default;
end;


procedure _mkHStrACT(ucl:byte;hint:shortstring);
var hk:shortstring;
begin
   if(ucl<=max_HotKeys)then
   begin
      hk:=HotKeyAction2Str(ucl);
      if(length(hk)>0)
      then str_hint_a[ucl]:=hint+' ('+hk+')'
      else str_hint_a[ucl]:=hint;
   end;
end;

procedure _mkHStrRPL(ucl:byte;hint:shortstring;noHK:boolean);
var hk:shortstring;
begin
   if(ucl<=max_HotKeys)then
   begin
      if(noHK)
      then hk:=''
      else hk:=HotKeyReplay2Str(ucl);
      if(length(hk)>0)
      then str_hint_r[ucl]:=hint+' ('+hk+')'
      else str_hint_r[ucl]:=hint;
   end;
end;
procedure _mkHStrOBS(ucl:byte;hint:shortstring;noHK:boolean);
var hk:shortstring;
begin
   if(ucl<=max_HotKeys)then
   begin
      if(noHK)
      then hk:=''
      else hk:=HotKeyObserver2Str(ucl);
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

procedure STRADD(s:pshortstring;ad,sep:shortstring);
begin
   if(length(ad)>0)then
     if(length(s^)=0)
     then s^:=ad
     else s^:=s^+sep+ad;
end;

function FindSourceProd(uid:byte):shortstring;
var i:byte;
   up,
   bp: shortstring;
begin
   up:='';
   bp:='';
   FindSourceProd:='';
   for i:=0 to 255 do
   begin
      if(uid in g_uids[i].ups_units  )then STRADD(@up,g_uids[i].un_txt_name,sep_comma);
      if(uid in g_uids[i].ups_builder)then STRADD(@bp,g_uids[i].un_txt_name,sep_comma);
   end;

   if(length(up)>0)then STRADD(@FindSourceProd,up,sep_comma);
   if(length(bp)>0)then STRADD(@FindSourceProd,bp,sep_comma);
end;


function str_UnitAttributes(pu:PTUnit;auid:byte):shortstring;
begin
   if(pu=nil)then
   begin
      pu:=@g_units[0];
      with pu^ do
      begin
         uidi:=auid;
         playeri:=0;
         player :=@g_players[playeri];
         _unit_apUID(pu);
         hits:=-32000;
      end;
   end;
   str_UnitAttributes:='';
   with pu^  do
   with uid^ do
   begin
      if(hits>fdead_hits)then
       if(hits>0)
       then STRADD(@str_UnitAttributes,str_attr_alive    ,sep_comma)
       else STRADD(@str_UnitAttributes,str_attr_dead     ,sep_comma);

      if(_ukbuilding)
      then STRADD(@str_UnitAttributes,str_attr_building  ,sep_comma)
      else STRADD(@str_UnitAttributes,str_attr_unit      ,sep_comma);
      if(_ukmech)
      then STRADD(@str_UnitAttributes,str_attr_mech      ,sep_comma)
      else STRADD(@str_UnitAttributes,str_attr_bio       ,sep_comma);
      if(_uklight)
      then STRADD(@str_UnitAttributes,str_attr_light     ,sep_comma)
      else STRADD(@str_UnitAttributes,str_attr_heavy     ,sep_comma);
      if(ukfly)
      then STRADD(@str_UnitAttributes,str_attr_fly       ,sep_comma)
      else
        if(ukfloater)
        then STRADD(@str_UnitAttributes,str_attr_floater,sep_comma)
        else STRADD(@str_UnitAttributes,str_attr_ground ,sep_comma);
      if(transportM>0)
      then STRADD(@str_UnitAttributes,str_attr_transport,sep_comma);
      if(level>0)then
        if(not _ukbuilding)
        or(_ukbuilding and (_isbarrack or _issmith))then STRADD(@str_UnitAttributes,str_attr_level+b2s(level+1),sep_comma);
      if(buff[ub_Detect]>0)or(_detector)
      then STRADD(@str_UnitAttributes,str_attr_detector,sep_comma);
      if(buff[ub_Invuln]>0)
      then STRADD(@str_UnitAttributes,str_attr_invuln,sep_comma)
      else
        if(buff[ub_Pain]>0)
        then STRADD(@str_UnitAttributes,str_attr_stuned,sep_comma);

      str_UnitAttributes:='['+str_UnitAttributes+tc_default+']';
   end;
end;

function BaseFlags2Str(flags:cardinal):shortstring;
function CheckFlags(f1,f2:cardinal;s1,s2:pshortstring;addifboth:boolean):boolean;
begin
   CheckFlags:=((flags and f1)>0)and((flags and f2)>0);
   if(addifboth)
   or( ((flags and f1)>0)<>((flags and f2)>0) )then
   begin
      if((flags and f1)>0)then STRADD(@BaseFlags2Str,s1^,sep_comma);
      if((flags and f2)>0)then STRADD(@BaseFlags2Str,s2^,sep_comma);
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


function str_DamageHint(dmod:byte):shortstring;
var i:byte;
begin
   str_DamageHint:='';
   for i:=0 to MaxDamageModFactors do
    with g_DamageMods[dmod][i] do
     if(dm_factor<>100)and(dm_flags>0)then
      STRADD(@str_DamageHint,'x'+l2s(dm_factor,100)+' '+BaseFlags2Str(dm_flags),sep_comma);
end;

function str_ReqNum2s(basename:shortstring;reqn:byte):shortstring;
begin
   str_ReqNum2s:=basename;
   if(reqn>1)then str_ReqNum2s+='(x'+b2s(reqn)+')';
end;

function AddReq(ruid,rupid,rupidl:byte):shortstring;
begin
  AddReq:='';
  if(ruid >0)then STRADD(@AddReq,'"'+str_ReqNum2s(g_uids [ruid ].un_txt_name,1     )+'"' ,sep_comma);
  if(rupid>0)then STRADD(@AddReq,'"'+str_ReqNum2s(g_upids[rupid]._up_name   ,rupidl)+'"' ,sep_comma);
  if(length(AddReq)>0)then AddReq:='{'+tc_yellow+str_req+tc_default+AddReq+'}';
end;

function str_MakeUnitDefaultDescription(uid:byte;basedesc:shortstring;for_doc:boolean):shortstring;
function RebuildStr(uid:byte;levelup:boolean):shortstring;
begin
  if(levelup)
  then RebuildStr:='"'+g_uids[uid].un_txt_name+'['+str_attr_level+'+1]"'
  else RebuildStr:='"'+g_uids[uid].un_txt_name+'"';
end;
begin
   str_MakeUnitDefaultDescription:='';
    with g_uids[uid] do
    begin
       if(not for_doc)then
       STRADD(@str_MakeUnitDefaultDescription,str_hits+i2s(_mhits),sep_sdot);
       //STRADD(@str_MakeUnitDefaultDescription,str_srange+i2s(_srange),sep_sdot);

       if(_isbuilder    )then STRADD(@str_MakeUnitDefaultDescription,str_builder,sep_sdot);
       if(_isbarrack    )then STRADD(@str_MakeUnitDefaultDescription,str_barrack,sep_sdot);
       if(_issmith      )then STRADD(@str_MakeUnitDefaultDescription,str_smith  ,sep_sdot);
       if(_genergy    >0)then STRADD(@str_MakeUnitDefaultDescription,str_IncEnergyLevel+'('+tc_aqua+'+'+i2s(_genergy)+tc_default+')',sep_sdot);
       if(_rebuild_uid>0)and(_ability<>uab_RebuildInPoint)then
       begin
          STRADD(@str_MakeUnitDefaultDescription,
          str_CanRebuildTo+
          RebuildStr(_rebuild_uid,_rebuild_uid=uid)+
          AddReq(_rebuild_ruid,_rebuild_rupgr,_rebuild_rupgrl),sep_sdot );
       end;
       if(_ability>0)then
       begin
          if(_ability=uab_RebuildInPoint)and(_rebuild_uid>0)
          then STRADD(@str_MakeUnitDefaultDescription,str_ability+str_transformation+RebuildStr(_rebuild_uid,uid=_rebuild_uid)+AddReq(_rebuild_ruid,_rebuild_rupgr,_rebuild_rupgrl),sep_sdot)
          else
            if(length(str_ability_name[_ability])>0)
            then STRADD(@str_MakeUnitDefaultDescription,str_ability+'"'+str_ability_name[_ability]+'"'+AddReq(_ability_ruid,_ability_rupgr,_ability_rupgrl),sep_sdot);
       end;

       if(_splashresist)or(_ukmech)then STRADD(@str_MakeUnitDefaultDescription,str_splashresist,sep_sdot);

       STRADD(@str_MakeUnitDefaultDescription,basedesc,sep_sdot);;
       if(length(str_MakeUnitDefaultDescription)>0)then str_MakeUnitDefaultDescription+='.';
    end;
end;

function str_WeaponTargets(tflags:cardinal;tset:TSoB):shortstring;
var u:byte;
  inset:TSoB;
  innum:byte;
  exset:TSoB;
  exnum:byte;
  instr,
  exstr:shortstring;
begin
  str_WeaponTargets:='';
  instr:='';
  exstr:='';
   if(tset<>uids_all     )then
    if(tset=uids_arch_res)
    then instr:='['+str_attr_dead+tc_default+','+str_demons+'] '+str_except+' ['+g_uids[UID_Cyberdemon].un_txt_name+','
                                                                                +g_uids[UID_Mastermind].un_txt_name+','
                                                                                +g_uids[UID_ArchVile  ].un_txt_name+']'
    else
     if(tset= uids_demons)
     then instr:='['+str_demons+']'
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
           STRADD(@instr,g_uids[u].un_txt_name,sep_comma);
         if(length(instr)>0)then instr:='['+instr+']';
      end;
      if(exnum<3)then
      begin
         for u:=1 to 255 do
          if(u in exset)then
           STRADD(@exstr,g_uids[u].un_txt_name,sep_comma);
         if(length(exstr)>0)then exstr:=str_except+' ['+exstr+']';
      end;
   end;

   if(length(instr)>0)
   then str_WeaponTargets:=instr
   else
     if(length(exstr)>0)
     then str_WeaponTargets:=BaseFlags2Str(tflags)+' '+exstr
     else str_WeaponTargets:=BaseFlags2Str(tflags);
end;

function str_MakeWeaponDPS(uid,wid:byte):shortstring;
var BaseDmg,
    ocount : integer;
    i,n    : byte;
    sps    : single;
begin
  str_MakeWeaponDPS:='';
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
        for i:=0 to aw_rld do
          if(i in aw_rld_s)then n+=1;
     end
     else n:=1;

     if(BaseDmg>0)then
     begin
        if(aw_type=wpt_heal)
        then STRADD(@str_MakeWeaponDPS,tc_lime+i2s(BaseDmg)+tc_default,'')
        else STRADD(@str_MakeWeaponDPS,tc_red +i2s(BaseDmg)+tc_default,'');

        if(ocount>1)
        then str_MakeWeaponDPS+='x'+i2s(ocount);
     end;

     if(aw_type=wpt_suicide)
     then sps:=1
     else
       if(aw_fakeshots>0)
       then sps:=(fr_fps1*n/aw_rld)/aw_fakeshots
       else sps:=(fr_fps1*n/aw_rld);
     STRADD(@str_MakeWeaponDPS,'*'+Float2Str(sps),'');
  end;
end;

function str_MakeWeaponString(uid,wid:byte;docSTR:boolean):shortstring;
const tab : array[false..true] of shortstring = ('-','- ');
var
dmod_str:shortstring;
begin
  with g_uids[uid] do
   with _a_weap[wid] do
   begin
      str_MakeWeaponString:='';
      case aw_type of
      0             : exit;
      wpt_missle,
      wpt_directdmg,
      wpt_directdmgZ: if(aw_max_range<0)
                      then STRADD(@str_MakeWeaponString,tab[docSTR]+str_weapon_melee    ,sep_scomma)
                      else STRADD(@str_MakeWeaponString,tab[docSTR]+str_weapon_ranged   ,sep_scomma);
      wpt_resurect  :      STRADD(@str_MakeWeaponString,tab[docSTR]+str_weapon_ressurect,sep_scomma);
      wpt_heal      :      STRADD(@str_MakeWeaponString,tab[docSTR]+str_weapon_heal     ,sep_scomma);
      wpt_unit      :      STRADD(@str_MakeWeaponString,tab[docSTR]+str_weapon_spawn+' "'+g_uids[aw_oid].un_txt_name+'"',sep_scomma);
      wpt_suicide   :      STRADD(@str_MakeWeaponString,tab[docSTR]+str_weapon_suicide  ,sep_scomma);
      end;

      if(docSTR)then
      begin
         if(aw_min_range>0)then
         STRADD(@str_MakeWeaponString,'min. range: '+i2s(aw_min_range),sep_scomma);

         if(aw_max_range=aw_srange)then
         begin
            STRADD(@str_MakeWeaponString,'max. range: vision range',sep_scomma);
            if(_a_BonusAntiFlyRange     <>0)then STRADD(@str_MakeWeaponString,'bonus anti-fly range: '     +i2sSign(_a_BonusAntiFlyRange     ),sep_scomma);
            if(_a_BonusAntiGroundRange  <>0)then STRADD(@str_MakeWeaponString,'bonus anti-ground range: '  +i2sSign(_a_BonusAntiFlyRange     ),sep_scomma);
            if(_a_BonusAntiUnitRange    <>0)then STRADD(@str_MakeWeaponString,'bonus anti-unit range: '    +i2sSign(_a_BonusAntiUnitRange    ),sep_scomma);
            if(_a_BonusAntiBuildingRange<>0)then STRADD(@str_MakeWeaponString,'bonus anti-building range: '+i2sSign(_a_BonusAntiBuildingRange),sep_scomma);
         end
         else
           if(aw_max_range<aw_srange) // melee
           then //STRADD(@str_MakeWeaponString,'max range: melee',sep_scomma)
           else
             if(aw_max_range>=aw_fsr0)then  // relative srange
             begin
                if(aw_max_range<>aw_fsr)
                then STRADD(@str_MakeWeaponString,'max. range: vision range'+i2sSign(aw_max_range-aw_fsr),sep_scomma)
                else STRADD(@str_MakeWeaponString,'max. range: vision range',sep_scomma);
             end
             else
             begin
                STRADD(@str_MakeWeaponString,'max. range: '+i2s(aw_max_range),sep_scomma);  // absolute
                if(_a_BonusAntiFlyRange     <>0)then STRADD(@str_MakeWeaponString,'bonus anti-fly range: '     +i2sSign(_a_BonusAntiFlyRange     ),sep_scomma);
                if(_a_BonusAntiGroundRange  <>0)then STRADD(@str_MakeWeaponString,'bonus anti-ground range: '  +i2sSign(_a_BonusAntiFlyRange     ),sep_scomma);
                if(_a_BonusAntiUnitRange    <>0)then STRADD(@str_MakeWeaponString,'bonus anti-unit range: '    +i2sSign(_a_BonusAntiUnitRange    ),sep_scomma);
                if(_a_BonusAntiBuildingRange<>0)then STRADD(@str_MakeWeaponString,'bonus anti-building range: '+i2sSign(_a_BonusAntiBuildingRange),sep_scomma);
             end;
      end;

      if(aw_type=wpt_directdmgZ)then
      STRADD(@str_MakeWeaponString,str_weapon_zombie,sep_scomma);

      STRADD(@str_MakeWeaponString,str_weapon_targets+str_WeaponTargets(aw_tarf,aw_uids),sep_scomma);

      STRADD(@str_MakeWeaponString,str_weapon_damage+' '+str_MakeWeaponDPS(uid,wid),sep_scomma);
      if(docSTR)then
      begin
         if(aw_type=wpt_missle)then
          with g_mids[aw_oid] do
           if(mid_base_splashr>0)then  STRADD(@str_MakeWeaponString,'splash damage radius: '+i2s(mid_base_splashr),sep_scomma);

         if(aw_type=wpt_suicide)and(_death_missile>0)then
          with g_mids[_death_missile] do
           if(mid_base_splashr>0)then  STRADD(@str_MakeWeaponString,'splash damage radius: '+i2s(mid_base_splashr),sep_scomma);

         dmod_str:='';
         case aw_tarprior of
wtp_Default      : dmod_str:='distance';
wtp_hits         : dmod_str:='lowest hits';
wtp_distance     : dmod_str:='distance';
wtp_building     : dmod_str:='buildings';
wtp_UnitBioLight : dmod_str:='[unit,bio,light]';
wtp_UnitBioHeavy : dmod_str:='[unit,bio,heavy]';
wtp_UnitMech     : dmod_str:='[unit,mech]';
wtp_UnitBio      : dmod_str:='[unit,bio]';
wtp_Bio          : dmod_str:='[bio]';
wtp_Light        : dmod_str:='[light]';
wtp_UnitLight    : dmod_str:='[unit,light]';
wtp_BuildingHeavy: dmod_str:='[building,heavy]';
wtp_heal         : dmod_str:='lowest hits';
wtp_Fly          : dmod_str:='[fly]';
wtp_nolost_hits  : dmod_str:='lowest hits';
wtp_max_hits     : dmod_str:='highest hits';
wtp_GroundLight  : dmod_str:='[ground,light]';
         end;
         if(length(dmod_str)>0)then
           STRADD(@str_MakeWeaponString,'target priority: '+dmod_str,sep_scomma);

         if(aw_dupgr>0)then
           STRADD(@str_MakeWeaponString,'upgrade: '+g_upids[aw_dupgr]._up_name+'('+i2sSign(aw_dupgr_s)+')',sep_scomma);
      end;

      dmod_str:='';

      case aw_type of
      wpt_suicide   : if(_death_missile>0)then dmod_str:=str_DamageHint(_death_missile_dmod);
      wpt_missle,
      wpt_directdmg,
      wpt_directdmgZ: if(aw_dmod>0)then dmod_str:=str_DamageHint(aw_dmod);
      end;

      if(length(dmod_str)>0)then
        if(docSTR)
        then STRADD(@str_MakeWeaponString,dmod_str,', factor: ')
        else STRADD(@str_MakeWeaponString,dmod_str,': '      );

      STRADD(@str_MakeWeaponString,AddReq(aw_ruid,aw_rupgr,aw_rupgr_l),sep_scomma);

      if(docSTR)then str_MakeWeaponString:=RemoveSpecChars(str_MakeWeaponString);
   end;
end;

function str_MakeWeaponsDescription(uid:byte;docSTR:boolean):shortstring;
var w:byte;
weapons_str:shortstring;
begin
  str_MakeWeaponsDescription:='';
  with g_uids[uid] do
  begin
     weapons_str:='';
     if(_attack=atm_always)then
      for w:=0 to MaxUnitWeapons do
       with _a_weap[w] do
        STRADD(@weapons_str,str_MakeWeaponString(uid,w,docSTR),sep_sdots);

     if(length(weapons_str)>0)then
      if(docSTR)
      then STRADD(@str_MakeWeaponsDescription,weapons_str,sep_sdot)
      else STRADD(@str_MakeWeaponsDescription,str_UnitArming+weapons_str,sep_sdot);
  end;
  if(length(str_MakeWeaponsDescription)>0)then str_MakeWeaponsDescription+='.';
end;

function str_makeUpgrBaseHint(upid,curlvl:byte):shortstring;
var HK,
    ENRG,
    TIME,
    INFO:shortstring;
    i   :byte;
begin
  with g_upids[upid] do
  begin
     HK  :=HotKeyBase2Str(_up_btni);
     ENRG:='';
     TIME:='';
     INFO:='';

     if(_up_max<=1)or(_up_mfrg)
     then curlvl:=1
     else
       if(curlvl>_up_max)and(curlvl<255)then curlvl:=_up_max;

     HK:=HotKeyBase2Str(_up_btni);
     if(_up_renerg>0)then
       if(curlvl<255)
       then ENRG:=tc_aqua +i2s(GetUpgradeEnergy(upid,curlvl))+tc_default
       else
         if(_up_max>0)then
         begin
            for i:=1 to _up_max do STRADD(@ENRG,i2s(GetUpgradeEnergy(upid,i)),'/');
            ENRG:=tc_aqua+ENRG+tc_default;
         end;
     if(_up_time  >0)then
       if(curlvl<255)
       then TIME:=tc_white+i2s(GetUpgradeTime(upid,curlvl)div fr_fps1)+tc_default
       else
         if(_up_max>0)then
         begin
            for i:=1 to _up_max do STRADD(@TIME,i2s(GetUpgradeTime(upid,i)div fr_fps1),'/');
            TIME:=tc_white+TIME+tc_default;
         end;
     if(length(HK  )>0)then STRADD(@INFO,HK  ,sep_comma);
     if(length(ENRG)>0)then STRADD(@INFO,ENRG,sep_comma);
     if(length(TIME)>0)then STRADD(@INFO,TIME,sep_comma);
     STRADD(@INFO,tc_orange+'x'+i2s(_up_max)+tc_default,sep_comma);
     if(_up_max>1)and(_up_mfrg)then STRADD(@INFO,tc_red+'*'+tc_default,sep_comma);

     str_makeUpgrBaseHint:=_up_name+' ('+INFO+')'+tc_nl1+tc_nl1+_up_descr;
  end;
end;

procedure str_makeHints;
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
         HK:=HotKeyBase2Str(_ucl);
         if(_renergy>0)then ENRG:=tc_aqua +i2s(_renergy)+tc_default;
         if(_btime  >0)then TIME:=tc_white+i2s(_btime  )+tc_default;
         LMT:=tc_orange+l2s(_limituse,MinUnitLimit)+tc_default;

         PROD:=FindSourceProd(uid);
         if(_ruid1>0)then STRADD(@REQ,str_ReqNum2s(g_uids [_ruid1].un_txt_name,_ruid1n),sep_comma);
         if(_ruid2>0)then STRADD(@REQ,str_ReqNum2s(g_uids [_ruid2].un_txt_name,_ruid2n),sep_comma);
         if(_ruid3>0)then STRADD(@REQ,str_ReqNum2s(g_uids [_ruid3].un_txt_name,_ruid3n),sep_comma);
         if(_rupgr>0)then STRADD(@REQ,str_ReqNum2s(g_upids[_rupgr]._up_name   ,_rupgrl),sep_comma);

         if(length(HK  )>0)then STRADD(@INFO,HK  ,sep_comma);
         if(length(ENRG)>0)then STRADD(@INFO,ENRG,sep_comma);
         if(length(LMT )>0)then STRADD(@INFO,LMT ,sep_comma);
         if(length(TIME)>0)then STRADD(@INFO,TIME,sep_comma);

         un_txt_fdescr :=str_MakeUnitDefaultDescription(uid,un_txt_udescr,false);

         un_txt_uihint1:=un_txt_name+' ('+INFO+')'+tc_nl1+str_UnitAttributes(nil,uid);
         un_txt_uihintS:=un_txt_name+tc_nl1;
         un_txt_uihint2:=un_txt_fdescr;
         un_txt_uihint3:=str_MakeWeaponsDescription(uid,false);
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

      if(_up_ruid  >0)then STRADD(@REQ,g_uids [_up_ruid ].un_txt_name,sep_comma);
      if(_up_rupgr >0)then STRADD(@REQ,g_upids[_up_rupgr]._up_name   ,sep_comma);

      _up_hint:='';
      if(length(REQ)>0)then _up_hint+=tc_yellow+str_requirements+tc_default+REQ;
   end;
end;

function str_Center0(src:shortstring;l:byte):shortstring;
begin
  str_Center0:=src ;
   if(length(src)<l)then
   begin
      l-=length(src);
      l:=l div 2;
      if(l<1)then l:=1;
      while(l>0)do
      begin
         str_Center0:=' '+str_Center0;
         l-=1;
      end;
   end;
end;

function str_AddSpaces(src:shortstring;size:byte):shortstring;
var l,i:byte;
begin
   src:=Trim(src);
   l:=length(src);
   i:=1;
   if(l>0)and(l>((size div 3)*2))and(pos(' ',src)>0)then
     while(l<size)do
     begin
        while(src[i]=' ') do
          if(i=l)
          then i:=1
          else i+=1;

        while(src[i]<>' ') do
          if(i=l)
          then i:=1
          else i+=1;

        insert(' ',src,i);
        l+=1;
     end;
   str_AddSpaces:=src;
end;

procedure str_AddToStrList(pslist:PTStringList;psln:pinteger;size:integer;newPara:boolean;newstr:shortstring);
var i,l,s:byte;
procedure AddToList(s:shortstring);
begin
   psln^+=1;
   setlength(pslist^,psln^);
   pslist^[psln^-1]:=s;
end;
begin
   if(psln^>0)and(newPara)then AddToList('');
   newstr:=trim(newstr);
   l:=length(newstr);
   i:=1;
   s:=255;
   while(l>0)do
   begin
      if(l<=size)then
      begin
         AddToList(newstr);
         break;
      end;

      if(i=size)or(i=l)then
      begin
         if(s=255)or(i=l)then s:=i;
         AddToList(str_AddSpaces(copy(newstr,1,s),size));
         delete(newstr,1,s);
         l:=length(newstr);
         i:=1;
         s:=255;
         continue;
      end;

      if(newstr[i]=' ')
      or(newstr[i]='-')
      or(newstr[i]=',')then s:=i;
      i+=1;
   end;
end;

procedure cmp_AddPlot(mission:byte;newPara:boolean;text:shortstring);
begin
   str_AddToStrList(@str_camp_infol[mission],@str_camp_infon[mission],37,newPara,text);
end;

function str_cmp_map(date,location,area:shortstring):shortstring;
begin
   str_cmp_map:=str_cmp_Date    +tc_nl2+
                  str_Center0(date    ,14)+tc_nl2+
                str_cmp_Location+tc_nl2+
                  str_Center0(location,14)+tc_nl2+
                str_cmp_Area    +tc_nl2+
                  str_Center0(area    ,14);
end;

procedure lng_eng;
var t: shortstring;
    i:byte;
begin
   str_Caption_Map               := 'MAP';
   str_Caption_Players           := 'PLAYERS';
   str_Caption_Multiplayer       := 'MULTIPLAYER';
   str_Caption_GOptions          := 'GAME OPTIONS';
   str_Caption_Server            := 'SERVER';
   str_Caption_Client            := 'CLIENT';

   str_MObjectives               := 'OBJECTIVES';

   str_menu_Tutorials            := 'TUTORIALS';
   str_menu_Campaings            := 'CAMPAIGNS';
   str_menu_Scirmish             := 'SKIRMISH';
   str_menu_Playback             := 'REPLAY PLAYBACK';
   str_menu_SaveLoad             := 'SAVE/LOAD';
   str_menu_LoadGame             := 'LOAD GAME';
   str_menu_Replays              := 'REPLAYS';
   str_menu_Settings             := 'SETTINGS';

   str_menu_Start                := 'START';
   str_menu_Surrender            := 'SURRENDER';
   str_menu_Break                := 'BREAK MISSION';
   str_menu_PlaybackStop         := 'STOP PLAYBACK';
   str_menu_Exit                 := 'EXIT';
   str_menu_Back                 := 'BACK';

   str_menu_SetGame              := 'GAME';
   str_menu_SetReplay            := 'RECORDING';
   str_menu_SetVideo             := 'VIDEO';
   str_menu_SetSound             := 'SOUND';

   str_SR_RecordGames            := 'Record games';
   str_SR_Quality                := 'File size/quality';
   str_SR_ReplayPrefix           := 'Replay prefix';

   str_SG_ShowAPM                := 'Show APM';
   str_SG_ColoredShadow          := 'Colored shadows';
   str_SG_ScrollSpeed            := 'Scroll speed';
   str_SG_MouseScroll            := 'Mouse scroll';
   str_SG_PlayerName             := 'Player name';
   str_SG_Language               := 'UI language';
   str_SG_LanguageL[true ]       := 'RUS';
   str_SG_LanguageL[false]       := 'ENG';
   str_SG_RightClickAct          := 'Right-click action';
   str_SG_RightClickActL[true ]  := tc_lime  +'move'  +tc_default;
   str_SG_RightClickActL[false]  := tc_lime  +'move'  +tc_default+'+'+tc_red+'attack'+tc_default;
   str_SG_ControlPanelPos        := 'Control panel position';
   str_SG_ControlPanelPosL[0]    := tc_lime  +'left'  +tc_default;
   str_SG_ControlPanelPosL[1]    := tc_orange+'right' +tc_default;
   str_SG_ControlPanelPosL[2]    := tc_yellow+'top'   +tc_default;
   str_SG_ControlPanelPosL[3]    := tc_aqua  +'bottom'+tc_default;
   str_SG_HealthBars             := 'Health bars';
   str_SG_HealthBarsL[0]         := tc_lime  +'selected'+tc_default+'+'+tc_red+'damaged'+tc_default;
   str_SG_HealthBarsL[1]         := tc_aqua  +'always'  +tc_default;
   str_SG_HealthBarsL[2]         := tc_orange+'only '   +tc_lime+'selected'+tc_default;
   str_SG_PlayersColor           := 'Players color';
   str_SG_PlayersColorL[0]       := tc_white +'default'+tc_default;
   str_SG_PlayersColorL[1]       := tc_lime  +'own '   +tc_yellow+'ally '+tc_red+'enemy'+tc_default;
   str_SG_PlayersColorL[2]       := tc_white +'own '   +tc_yellow+'ally '+tc_red+'enemy'+tc_default;
   str_SG_PlayersColorL[3]       := tc_white +'own '   +tc_aqua  +'ally '+tc_red+'enemy'+tc_default;
   str_SG_PlayersColorL[4]       := tc_purple+'teams'  +tc_default;
   str_SG_PlayersColorL[5]       := tc_white +'own '   +tc_purple+'teams'+tc_default;

   str_SV_Windowed               := 'Windowed';
   str_SV_ResolutionApply        := 'Apply resolution';
   str_SV_ResolutionW            := 'Resolution (width)';
   str_SV_ResolutionH            := 'Resolution (height)';
   str_SV_MenuScale              := 'Menu scaling';
   str_SV_MenuScaleSmooth        := 'Smooth scaled menu';
   str_SV_ShowFPS                := 'Show FPS';

   str_SS_MusicVolume            := 'Music volume';
   str_SS_SoundVolume            := 'Sound volume';
   str_SS_NextTrack              := 'Play next track';
   str_SS_ReloadMusic            := 'Load new playlist';
   str_SS_MusicListSize          := 'Music playlist size';

   str_GO_AISlots                := 'Fill empty slots';
   str_GO_FixedStarts            := 'Fixed player starts';
   str_GO_DefeatedObs            := 'Observer mode after lose';
   str_GO_Random                 := 'Random skirmish';

   str_map                       := 'Map';
   str_map_Seed                  := 'Seed';
   str_map_Size                  := 'Size';
   str_map_Obstacles             := 'Obstacles';
   str_map_Symmetry              := 'Symmetric';
   str_map_Random                := 'Random map';

   str_map_Scenario              := 'Scenario';
   str_map_ScenarioL[mc_scirmish]:= tc_lime  +'Skirmish'    +tc_default;
   str_map_ScenarioL[mc_3x3     ]:= tc_orange+'3x3'         +tc_default;
   str_map_ScenarioL[mc_2x2x2   ]:= tc_yellow+'2x2x2'       +tc_default;
   str_map_ScenarioL[mc_capture ]:= tc_aqua  +'Key points'  +tc_default;
   str_map_ScenarioL[mc_invasion]:= tc_blue  +'Invasion'    +tc_default;
   str_map_ScenarioL[mc_KotH    ]:= tc_purple+'KotH'        +tc_default;
   str_map_ScenarioL[mc_royale  ]:= tc_red   +'Royal Battle'+tc_default;

   str_map_Generators            := 'Generators';
   str_map_GeneratorsL[0]        := 'no';
   str_map_GeneratorsL[1]        := '5 min';
   str_map_GeneratorsL[2]        := '10 min';
   str_map_GeneratorsL[3]        := '15 min';
   str_map_GeneratorsL[4]        := '20 min';
   str_map_GeneratorsL[5]        := 'infinity';

   str_FileError_NExists         := 'File not'+tc_nl3+'exists!';
   str_FileError_Open            := 'Can`t open'+tc_nl3+'file!';
   str_FileError_WData           := 'Wrong file'+tc_nl3+'data!';
   str_FileError_WVer            := 'Wrong version!';

   str_PT_Player                 := 'PLAYER';
   str_PT_State                  := 'STATUS';
   str_PT_Race                   := 'RACE';
   str_PT_Team                   := 'TEAM';
   str_PT_Color                  := 'COLOR';
   str_PT_Ping                   := 'PING+';

   str_race[r_random]            := tc_default+'RANDOM'+tc_default;
   str_race[r_hell  ]            := tc_orange +'HELL'  +tc_default;
   str_race[r_uac   ]            := tc_lime   +'UAC'   +tc_default;

   str_FileInfo                  := 'FILE INFO';
   str_FileSave                  := 'Save';
   str_FileLoad                  := 'Load';
   str_FileDelete                := 'Delete';

   str_observer          := 'OBSERVER';
   str_win               := 'VICTORY!';
   str_lose              := 'DEFEAT!';
   str_gsunknown         := 'Unknown status!';
   str_pause             := 'Pause';
   str_gsaved            := 'Game saved';
   str_repend            := 'Replay ended!';
   str_reperror          := 'Read file error!';

   str_Players           := 'Players';

   str_time              := 'Time: ';
   str_menu              := 'Menu';

   str_inv_time          := 'Wave #';
   str_inv_ml            := 'Monsters limit: ';
   str_ReplayPlay        := 'Play';


   str_WaitForServer     := 'Awaiting server...';


   str_menu_chat         := 'CHAT(ALL PLAYERS)';
   str_chat_all          := 'ALL:';
   str_chat_allies       := 'ALLIES:';


   str_PlayerDefeat      := ' was terminated!';
   str_PlayerLeft        := ' left the game';
   str_PlayerSurrender   := ' surrenders!';


   str_requirements      := 'Requirements: ';
   str_req               := 'Req.: ';
   str_orders            := 'Unit groups: ';
   str_all               := 'All';
   str_uprod             := tc_lime+'Produced by: '   +tc_default;
   str_bprod             := tc_lime+'Constructed by: '+tc_default;

   str_kothtime          := 'Center capture time left: ';
   str_kothtime_act      := 'Time left until center area is active: ';
   str_kothwinner        := ' is King of the Hill!';



   str_ability           := 'Special ability: ';
   str_transformation    := 'transformation to ';
   str_upgradeslvl       := 'Upgrades: ';
   str_demons            := 'demons&zombies';
   str_except            := 'except';
   str_splashresist      := 'Immune to splash damage';
   str_TargetLimit       := 'target limit';
   str_PlayerPaused      := 'player paused the game';
   str_PlayerResumed     := 'player has resumed the game';

   str_menu_controls     := '- use the left and right mouse buttons to manipulate the menu items -';
   str_RecordingStart    := 'Start recording: ';
   str_RecordingStop     := 'Stop recording: ';


   str_builder           := 'Builder';
   str_barrack           := 'Unit production';
   str_smith             := 'Researches and upgrades facility';
   str_IncEnergyLevel    := 'Increase energy level';
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

   str_cant_land         := 'Can`t land or teleport here';
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
   str_cpoint_captured   := 'The Key point was captured!';
   str_cpoint_lost       := 'The Key point was lost!';
   str_koth_control      := ' team starts controlling the center!';
   str_ngen_captured     := 'The Neutral Generator was captured!';
   str_ngen_lost         := 'The Neutral Generator was lost!';
   str_ngen_exh          := 'The Neutral Generator was exhausted!';
   str_invalid_target    := 'Invalid target!';

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

   str_ReplayQualityL[0]           := tc_aqua  +'x1 '+tc_default+'/'+tc_red   +' x1';
   str_ReplayQualityL[1]           := tc_aqua  +'x2 '+tc_default+'/'+tc_red   +' x2';
   str_ReplayQualityL[2]           := tc_lime  +'x3 '+tc_default+'/'+tc_orange+' x3';
   str_ReplayQualityL[3]           := tc_lime  +'x4 '+tc_default+'/'+tc_orange+' x4';
   str_ReplayQualityL[4]           := tc_yellow+'x5 '+tc_default+'/'+tc_yellow+' x5';
   str_ReplayQualityL[5]           := tc_yellow+'x6 '+tc_default+'/'+tc_yellow+' x6';
   str_ReplayQualityL[6]           := tc_orange+'x7 '+tc_default+'/'+tc_lime  +' x7';
   str_ReplayQualityL[7]           := tc_orange+'x8 '+tc_default+'/'+tc_lime  +' x8';
   str_ReplayQualityL[8]           := tc_red   +'x9 '+tc_default+'/'+tc_aqua  +' x9';
   str_ReplayQualityL[9]           := tc_red   +'x10'+tc_default+'/'+tc_aqua  +' x10';

   str_NetQualityL[0]          := tc_red   +'x1 ';
   str_NetQualityL[1]          := tc_red   +'x2 ';
   str_NetQualityL[2]          := tc_orange+'x3 ';
   str_NetQualityL[3]          := tc_orange+'x4 ';
   str_NetQualityL[4]          := tc_yellow+'x5 ';
   str_NetQualityL[5]          := tc_yellow+'x6 ';
   str_NetQualityL[6]          := tc_lime  +'x7 ';
   str_NetQualityL[7]          := tc_lime  +'x8 ';
   str_NetQualityL[8]          := tc_aqua  +'x9 ';
   str_NetQualityL[9]          := tc_aqua  +'x10';

   str_Camp_Difficulty   := 'Difficulty';
   str_Camp_DifficultyL[0]           := tc_aqua  +'I`m too young to die'+tc_default;
   str_Camp_DifficultyL[1]           := tc_lime  +'Hey, not too rough'  +tc_default;
   str_Camp_DifficultyL[2]           := tc_yellow+'Hurt me plenty'      +tc_default;
   str_Camp_DifficultyL[3]           := tc_orange+'Ultra-Violence'      +tc_default;
   str_Camp_DifficultyL[4]           := tc_red   +'Nightmare'           +tc_default;


   str_net_Ready         := 'Ready';
   str_net_UDPPort       := 'UDP port';
   str_net_ServerStart   := 'Start server';
   str_net_ServerStop    := 'Stop server';
   str_net_Connect       := 'Connect';
   str_net_Disconnect    := 'Disconnect';
   str_net_Quality       := 'Units update rate';
   str_net_Address       := 'Address';
   str_net_LANSearch     := 'Search for LAN servers';

   str_connecting        := 'Connecting...';
   str_portblocked       := 'Port is blocked!';

   str_msg_WrongVersion  := 'Wrong version!';
   str_msg_ServerFull    := 'Server full!';
   str_msg_GameStarted   := 'Game started!';

   str_hint_Tab[0]         := 'Buildings';
   str_hint_Tab[1]         := 'Units';
   str_hint_Tab[2]         := 'Researches';
   str_hint_Tab[3]         := 'Controls';

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
   str_ability_name[uab_ToUACDron       ]:='Deconstruct to Drone';
   str_ability_name[uab_Unload          ]:='Unload';
   str_ability_reloading:='The ability is on cooldown!' ;

   _mkHStrUid(UID_HKeep          ,'Hell Keep'                   ,'');
   _mkHStrUid(UID_HAKeep         ,'Great Hell Keep'             ,'');
   _mkHStrUid(UID_HGate          ,'Demon`s Gate'                ,'');
   _mkHStrUid(UID_HSymbol1       ,'Unholy Symbol level 1'       ,'');
   _mkHStrUid(UID_HSymbol2       ,'Unholy Symbol level 2'       ,'');
   _mkHStrUid(UID_HSymbol3       ,'Unholy Symbol level 3'       ,'');
   _mkHStrUid(UID_HSymbol4       ,'Unholy Symbol level 4'       ,'');
   _mkHStrUid(UID_HPools         ,'Infernal Pools'              ,'');
   _mkHStrUid(UID_HTeleport      ,'Teleport'                    ,'Base teleportation cooldown is '+tc_aqua+i2s(hteleport_rldPerLimit)+tc_default+'*[limit of teleported unit]');
   _mkHStrUid(UID_HPentagram     ,'Pentagram of Death'          ,'');
   _mkHStrUid(UID_HMonastery     ,'Monastery of Despair'        ,'');
   _mkHStrUid(UID_HFortress      ,'Castle of Damned'            ,'');
   _mkHStrUid(UID_HTower         ,'Guard Tower'                 ,'Basic defensive structure'        );
   _mkHStrUid(UID_HTotem         ,'Totem of Horror'             ,'Advanced defensive structure'     );
   _mkHStrUid(UID_HAltar         ,'Altar of Pain'               ,'The duration of the "'+str_ability_name[uab_HInvulnerability]+'" effect is '+i2s(invuln_time_sec)+' sec., the ability reload time is '+tc_aqua+i2s(haltar_reload_sec)+tc_default+' sec');
   _mkHStrUid(UID_HCommandCenter ,'Hell Command Center'         ,'Corrupted Command Center'         );
   _mkHStrUid(UID_HACommandCenter,'Advanced Hell Command Center','Corrupted Advanced Command Center');
   _mkHStrUid(UID_HBarracks      ,'Zombie Barracks'             ,'Corrupted Barracks'               );
   _mkHStrUid(UID_HEyeNest       ,'Evil Eye Nest'               ,'Detection structure. Reload time of the ability is '+tc_aqua+i2s(hell_vision_reload_sec)+tc_default+' sec'   );

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
   _mkHStrUid(UID_ZMedic         ,'Zombie Medic'                ,'');
   _mkHStrUid(UID_ZEngineer      ,'Zombie Engineer'             ,'');
   _mkHStrUid(UID_ZSergant       ,'Zombie Shotguner'            ,'');
   _mkHStrUid(UID_ZSSergant      ,'Zombie SuperShotguner'       ,'');
   _mkHStrUid(UID_ZCommando      ,'Zombie Commando'             ,'');
   _mkHStrUid(UID_ZAntiaircrafter,'Zombie Antiaircrafter'       ,'');
   _mkHStrUid(UID_ZSiegeMarine   ,'Zombie Siege Marine'         ,'');
   _mkHStrUid(UID_ZFPlasmagunner ,'Zombie Plasmaguner'          ,'');
   _mkHStrUid(UID_ZBFGMarine     ,'Zombie BFG Marine'           ,'');


   _mkHStrUpid(upgr_hell_t1attack  ,'Hell Firepower'                ,'Increase the damage of ranged attacks for T1 units and defensive structures');
   _mkHStrUpid(upgr_hell_uarmor    ,'Combat Flesh'                  ,'Increase the armor of all Hell units'                                   );
   _mkHStrUpid(upgr_hell_barmor    ,'Stone Walls'                   ,'Increase the armor of all Hell buildings'                               );
   _mkHStrUpid(upgr_hell_mattack   ,'Claws and Teeth'               ,'Increase the damage of melee attacks'                                   );
   _mkHStrUpid(upgr_hell_regen     ,'Flesh Regeneration'            ,'Health regeneration for all Hell units'                                 );
   _mkHStrUpid(upgr_hell_pains     ,'Pain Threshold'                ,'Hell units can take more hits before being stunned by pain'             );
   _mkHStrUpid(upgr_hell_towers    ,'Demonic Spirits'               ,'Increase the range of defensive structures'                             );
   _mkHStrUpid(upgr_hell_HKTeleport,'Hell Keep Blink Charge'        ,'Charge for Hell Keep`s ability'                                         );
   _mkHStrUpid(upgr_hell_paina     ,'Decay Aura'                    ,'Hell Keep start damage all enemies around. Decay Aura damage ignores unit armor');
   _mkHStrUpid(upgr_hell_buildr    ,'Hell Keep Range Upgrade'       ,'Increase Hell Keep`s range of vision'                                   );

   _mkHStrUpid(upgr_hell_spectre   ,'Specters'                      ,'Pinky Demon becomes invisible'                                  );
   _mkHStrUpid(upgr_hell_vision    ,'Hell Sight'                    ,'Increase the sight range of all Hell units'                     );
   _mkHStrUpid(upgr_hell_phantoms  ,'Phantoms'                      ,'Pain Elemental spawns Phantoms instead of Lost Soul'            );
   _mkHStrUpid(upgr_hell_t2attack  ,'Demon`s Weapons'               ,'Increase the damage of ranged attacks for T2 units and defensive structures'  );
   _mkHStrUpid(upgr_hell_teleport  ,'Teleport Upgrade'              ,'Reduced cooldown on Teleport ability'                           );
   _mkHStrUpid(upgr_hell_rteleport ,'Recall'                        ,'The Teleport can recall units'                                  );
   _mkHStrUpid(upgr_hell_heye      ,'Evil Eye Upgrade'              ,'Increase the sight range of Evil Eye'                           );
   _mkHStrUpid(upgr_hell_totminv   ,'Totem of Horror Invisibility'  ,'Totem of Horror becomes invisible'                              );
   _mkHStrUpid(upgr_hell_bldrep    ,'Building Restoration'          ,'Health regeneration for all Hell buildings'                     );
   _mkHStrUpid(upgr_hell_tblink    ,'Tower Teleportation Charge'    ,'Charges for ability of Guard Tower and Totem of Horror');
   _mkHStrUpid(upgr_hell_resurrect ,'Resurrection'                  ,'ArchVile`s ability'                    );


   _mkHStrUid(UID_UCommandCenter   ,'Command Center'                ,''      );
   _mkHStrUid(UID_UACommandCenter  ,'Advanced Command Center'       ,''      );
   _mkHStrUid(UID_UBarracks        ,'Barracks'                      ,''      );
   _mkHStrUid(UID_UFactory         ,'Vehicle Factory'               ,''      );
   _mkHStrUid(UID_UGenerator1      ,'Generator level 1'             ,''      );
   _mkHStrUid(UID_UGenerator2      ,'Generator level 2'             ,''      );
   _mkHStrUid(UID_UGenerator3      ,'Generator level 3'             ,''      );
   _mkHStrUid(UID_UGenerator4      ,'Generator level 4'             ,''      );
   _mkHStrUid(UID_UWeaponFactory   ,'Weapon Factory'                ,''      );
   _mkHStrUid(UID_UGTurret         ,'Anti-ground Turret'            ,'Anti-ground defensive structure');
   _mkHStrUid(UID_UATurret         ,'Anti-air Turret'               ,'Anti-air defensive structure'   );
   _mkHStrUid(UID_UTechCenter      ,'Science Facility'              ,'');
   _mkHStrUid(UID_UComputerStation ,'Computer Station'              ,'');
   _mkHStrUid(UID_URadar           ,'Radar'                         ,'Reveals map. Reload time of the ability is '+tc_aqua+i2s(radar_reload_sec)+tc_default+' sec');
   _mkHStrUid(UID_URMStation       ,'Rocket Launcher Station'       ,'The "'+str_ability_name[uab_UACStrike]+'" impact is '+tc_red+i2s(g_mids[MID_Blizzard].mid_base_damage)+tc_default+': ' +str_DamageHint(dm_RSMShot)+', the ability reload time is '+tc_aqua+i2s(mstrike_reload_sec)+tc_default+' sec');
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


   _mkHStrUpid(upgr_uac_attack     ,'Weapons Upgrade'                  ,'Increase the damage of ranged attacks for all UAC units and defensive structures');
   _mkHStrUpid(upgr_uac_uarmor     ,'Infantry Combat Armor Upgrade'    ,'Increase the armor of all Barrack`s units'                     );
   _mkHStrUpid(upgr_uac_barmor     ,'Concrete Walls'                   ,'Increase the armor of all UAC buildings'                       );
   _mkHStrUpid(upgr_uac_melee      ,'Advanced Tools'                   ,'Increase repair/healing efficiency of Engineers/Medics'        );
   _mkHStrUpid(upgr_uac_mspeed     ,'Lightweight Armor'                ,'Increase the movement speed of all Barrack`s units'            );
   _mkHStrUpid(upgr_uac_ssgup      ,'Expansive bullets'                ,'Attacks of Shotguner, SuperShotguner and Terminator are more likely to cause a pain state' );
   _mkHStrUpid(upgr_uac_towers     ,'Spotlights'                       ,'Increase the range of defensive structures'                    );
   _mkHStrUpid(upgr_uac_CCFly      ,'Command Center Flight Engines'    ,'Command Center gains ability to fly'                           );
   _mkHStrUpid(upgr_uac_ccturr     ,'Command Center Turret'            ,'Plasma turret for Command Center'                              );
   _mkHStrUpid(upgr_uac_buildr     ,'Command Center Range Upgrade'     ,'Increase Command Center`s range of vision'                           );

   _mkHStrUpid(upgr_uac_botturret  ,'Drone Transformation Protocol'    ,'Drone can rebuild to Anti-ground turret'    );
   _mkHStrUpid(upgr_uac_vision     ,'Light Amplification Visors'       ,'Increase the sight range of all UAC units'  );
   _mkHStrUpid(upgr_uac_commando   ,'Stealth Technology'               ,'Commando becomes invisible'                 );
   _mkHStrUpid(upgr_uac_airsp      ,'Fragmentation Missiles'           ,'Anti-air missiles do extra damage around the target'     );
   _mkHStrUpid(upgr_uac_mechspd    ,'Advanced Engines'                 ,'Increase the movement speed of all Factory`s units'      );
   _mkHStrUpid(upgr_uac_mecharm    ,'Mech Combat Armor Upgrade'        ,'Increase the armor of all Factory`s units'               );
   _mkHStrUpid(upgr_uac_antiair    ,'Anti-air Weapon'                  ,'Anti-air weapon for Terminator'                          );
   _mkHStrUpid(upgr_uac_transport  ,'Dropship Upgrade'                 ,'Increase the capacity of Dropship'                       );
   _mkHStrUpid(upgr_uac_radar_r    ,'Radar Upgrade'                    ,'Increase radar scanning radius'             );
   _mkHStrUpid(upgr_uac_plasmt     ,'Anti-ground Plasmagun'            ,'Anti-['+str_attr_mech+'] weapon for Anti-ground turret'  );
   _mkHStrUpid(upgr_uac_turarm     ,'Additional Armoring'              ,'Additional armor for Turrets'               );

   str_action_hint[iAct_Control_USelArmy     ]:= 'Select all battle units';

   str_action_hint[iAct_Control_UAbility1       ]:= '';
   str_action_hint[iAct_Control_UAbility2       ]:= '';
   str_action_hint[iAct_Control_UAbility3       ]:= '';
   str_action_hint[iAct_Control_UDestroy         ]:= 'Destroy';

  { str_action_hint[iAct_Control_UAMove          ]:= 101;
   str_action_hint[iAct_Control_UAStop          ]:= 102;
   str_action_hint[iAct_Control_UAPatrol        ]:= 103;
   str_action_hint[iAct_Control_UMove           ]:= 104;
   str_action_hint[iAct_Control_UStop           ]:= 105;
   str_action_hint[iAct_Control_UPatrol         ]:= 106;

   str_action_hint[iAct_Replay_Fast     ]:= 110;
   str_action_hint[iAct_Replay_Back     ]:= 111;
   str_action_hint[iAct_Replay_Forward  ]:= 112;
   str_action_hint[iAct_Replay_Pause    ]:= 113;
   str_action_hint[iAct_Replay_POV      ]:= 114;
   str_action_hint[iAct_Replay_Log      ]:= 115;
   str_action_hint[iAct_Replay_Fog      ]:= 116;
   str_action_hint[iAct_Replay_Player1  ]:= 117;
   str_action_hint[iAct_Replay_Player2  ]:= 118;
   str_action_hint[iAct_Replay_Player3  ]:= 119;
   str_action_hint[iAct_Replay_Player4  ]:= 120;
   str_action_hint[iAct_Replay_Player5  ]:= 121;
   str_action_hint[iAct_Replay_Player6  ]:= 122;

   str_action_hint[iAct_Observer_Fog    ]:= 125;
   str_action_hint[iAct_Observer_Player1]:= 126;
   str_action_hint[iAct_Observer_Player2]:= 127;
   str_action_hint[iAct_Observer_Player3]:= 128;
   str_action_hint[iAct_Observer_Player4]:= 129;
   str_action_hint[iAct_Observer_Player5]:= 130;
   str_action_hint[iAct_Observer_Player6]:= 131;  }

   //_mkHStrACT(0 ,str_sability );
   //_mkHStrACT(1 ,str_spability);
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
   _mkHStrACT(10,'Select all battle units' );
   _mkHStrACT(11,''          );
   _mkHStrACT(12,'Alarm mark'       );
   _mkHStrACT(13,str_SG_RightClickAct);

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

   FillChar(str_menu_hint,sizeOf(str_menu_hint),0);

   for i in byte do str_menu_hint[i]:=b2s(i);

   {for i in [6,7,106,8,9,10,12,13,18,20,22,23,27,26,29,31,38,39,40,42,44,53,56,62,74,76,79,82,86,89] do
   str_menu_hint[i]:='LMB';

   for i in [14,116,117,16,30,51,52,63,77,78,84,91,193,194,92,97] do
   str_menu_hint[i]:='LMB/RMB';

   for i in [87,90,11,83] do
   str_menu_hint[i]:='LMB: select for edition';

   str_menu_hint[50]:='LMB: select for edition; RMB: set random value';
   str_menu_hint[60]:='LMB: change AI player skill; RMB: jump to position';
   str_menu_hint[61]:='LMB: add/remove AI player';
   str_menu_hint[80]:='LMB: make random scirmish settings, RMB: make&run game'; }

   /////////////////////////////////////////////////////////////////////////////

   str_cmp_unk       := 'UNKNOWN';
   str_cmp_Date      := tc_gray+'Date: '    +tc_default;
   str_cmp_Location  := tc_gray+'Location: '+tc_default;
   str_cmp_Area      := tc_gray+'Area: '    +tc_default;

   str_camp_MissionName[0 ] := 'Hell#1: And Hell Followed (Tutorial)';
   str_camp_MissionName[1 ] := 'Hell#2: Invasion to the Phobos';
   str_camp_MissionName[2 ] := 'Hell#3: The Military Industry';
   str_camp_MissionName[3 ] := 'Hell#4: the Deimos Anomaly';
   str_camp_MissionName[4 ] := 'Hell#5: Nuclear Moon';
   str_camp_MissionName[5 ] := 'Hell#6: Fear';
   str_camp_MissionName[6 ] := 'Hell#7: Ghosts of Mars';
   str_camp_MissionName[7 ] := 'Hell#8: ';
   str_camp_MissionName[8 ] := 'Hell#9: Hell on Mars';
   str_camp_MissionName[9 ] := 'Hell#10: Hell On Earth';
   str_camp_MissionName[10] := 'Hell#11: Industrial Zone';
   str_camp_MissionName[11] := 'Hell#12: Cosmodrome';

   str_camp_MissionName[12] := 'UAC#1: Command Center';
   str_camp_MissionName[13] := 'UAC#2: Super Generators';
   str_camp_MissionName[14] := 'UAC#3: Phobos Anomaly';
   str_camp_MissionName[15] := 'UAC#4: Deimos Anomaly 2';
   str_camp_MissionName[16] := 'UAC#5: Lab';
   str_camp_MissionName[17] := 'UAC#6: Fortress of Mystery';
   str_camp_MissionName[18] := 'UAC#7: City of the Damned';
   str_camp_MissionName[19] := 'UAC#8: Slough of Despair';
   str_camp_MissionName[20] := 'UAC#9: Mt. Erebus';
   str_camp_MissionName[21] := 'UAC#10: Dead Zone';
   str_camp_MissionName[22] := 'UAC#11:    ';
   str_camp_MissionName[23] := 'UAC#12: Battle For Mars';

   str_camp_map [0 ] := str_cmp_map(str_cmp_unk ,'HELL WORLD','Portal valley');
   str_camp_map [1 ] := str_cmp_map('15.11.2145','PHOBOS'    ,'Hall crater'   );
   str_camp_map [2 ] := str_cmp_map('16.11.2145','PHOBOS'    ,'Drunlo crater' );
   str_camp_map [3 ] := str_cmp_map('15.11.2145','DEIMOS'    ,'Anomaly Zone'  );
   str_camp_map [4 ] := str_cmp_map('16.11.2145','DEIMOS'    ,'Swift crater'  );
   str_camp_map [5 ] := str_cmp_map('16.11.2145','DEIMOS'    ,'Voltaire Area' );
   str_camp_map [6 ] := str_cmp_map('16.11.2145','MARS'      ,'Hellas Area');
   str_camp_map [7 ] := str_cmp_map('16.11.2145','MARS'      ,'Hellas Area');
   str_camp_map [8 ] := str_cmp_map('16.11.2145','MARS'      ,'Hellas Area');
   str_camp_map [9 ] := str_cmp_map('25.11.2145','EARTH'     ,'Unknown');
   str_camp_map [10] := str_cmp_map('26.11.2145','EARTH'     ,'Unknown');
   str_camp_map [11] := str_cmp_map('27.11.2145','EARTH'     ,'Unknown');

   str_camp_map [12] := str_cmp_map('16.11.2145','PHOBOS'    ,'Todd crater'  );
   str_camp_map [13] := str_cmp_map('16.11.2145','PHOBOS'    ,'Roche crater' );
   str_camp_map [14] := str_cmp_map('17.11.2145','PHOBOS'    ,'Anomaly Zone' );
   str_camp_map [15] := str_cmp_map('17.11.2145','DEIMOS'    ,'Anomaly Zone' );
   str_camp_map [16] := str_cmp_map('18.11.2145','DEIMOS'    ,'Voltaire Area');
   str_camp_map [17] := str_cmp_map('18.11.2145','DEIMOS'    ,'Voltaire Area');
   str_camp_map [18] := str_cmp_map('20.11.2145','HELL'      ,'Portal valley');
   str_camp_map [19] := str_cmp_map('21.11.2145','HELL'      ,'Unknown'      );
   str_camp_map [20] := str_cmp_map('22.11.2145','HELL'      ,'Unknown'      );
   str_camp_map [21] := str_cmp_map('21.11.2145','MARS'      ,'Hellas Area');
   str_camp_map [22] := str_cmp_map('21.11.2145','MARS'      ,'Hellas Area');
   str_camp_map [23] := str_cmp_map('22.11.2145','MARS'      ,'Hellas Area');

   for i:=0 to LastMission do
   begin
      setlength(str_camp_infol[i],0);
      str_camp_infon[i]:=0;
   end;

   ////   HELL #1 / Tutorial

   cmp_AddPlot(0,false,
'This planet looks terrifying: fire everywhere, molten lava, and eerie creatures. It is located far among thousands of other worlds belonging to a powerful galactic Empire. Everything here remained unchanged for many centuries after the conquest...');
   cmp_AddPlot(0,false,
'until suddenly the old teleporter, built by some ancient civilization, was activated. Technologically advanced aliens arrived from the portal, immediately starting to explore the new territory.');

   cmp_AddPlot(0,true ,
'You are one of the higher demons, whose calling is to lead the demonic army into battle. You were recently promoted to your current rank and have not yet had the chance to prove yourself.');
   cmp_AddPlot(0,false,
'Your first task is to study the aliens, infiltrate their world, and subjugate it to the will of the Empire.');

   cmp_AddPlot(0,true,
'The invaders have built a large camp near the Portal, and we don`t even have a small outpost in this region. It is necessary to quickly build a base, summon the army, and crush the violators!');

   cmp_AddPlot(0,true ,'- Reach 2000 energy level');
   cmp_AddPlot(0,false,'- Build 4 Demon`s Gates'  );
   cmp_AddPlot(0,false,'- Summon 30 Hell warriors');
   cmp_AddPlot(0,false,'- Do not lose Hell Keeps' );
   cmp_AddPlot(0,false,'- Destroy all intruder creatures');


  {


   str_camp_obj [2 ] := '- Destroy Military Base';

   str_camp_obj [3 ] := '- Destroy all human bases and armies'+tc_nl2+'-Cyberdemon must survive'+tc_nl2+'-Protect portal';
   str_camp_obj [4 ] := '- Destroy Nuclear Plant'+tc_nl2+'-Cyberdemon must survive';
   str_camp_obj [5 ] := '- Destroy Science Center'+tc_nl2+'-Cyberdemon must survive';

   str_camp_obj [6 ] := '- Destroy all human bases and armies';
   str_camp_obj [7 ] := '???';
   str_camp_obj [8 ] := '- Kill all humans!';
   str_camp_obj [9 ] := '- Protect Hell Fortess'+tc_nl2+'-Destroy all human towns and armies';
   str_camp_obj [10] := '- Destroy all industrial buildings'+tc_nl2+'-Destroy all command centers';
   str_camp_obj [11] := '- Destroy all military bases';

   str_camp_obj [12] := '- Find, protect and reapir'+tc_nl2+'Command Center'+tc_nl2+'-At least one engineer must survive';
   str_camp_obj [13] := '- Find and repair 5 Super Generators';
   str_camp_obj [14] := '- Destroy all bases and armies of hell'+tc_nl2+'around portal until the arrival of'+tc_nl2+'enemy reinforcements(for 20 minutes)';

   str_camp_obj [15] := '- Destroy all bases and armies of hell'+tc_nl2+'-Protect portal';
   str_camp_obj [16] := '- Repair and protect Science Center'+tc_nl2+'-Destroy all bases and armies of hell';
   str_camp_obj [17] := '- Destroy fortess of hell';

   str_camp_obj [18] := '- Destroy all altars of hell'+tc_nl2+'-Protect portal';
   str_camp_obj [19] := '- Reach the opposite side of the area';
   str_camp_obj [20] := '- Find and kill the Spiderdemon';

   str_camp_obj [21] := '- Cleanse the Quarry';
   str_camp_obj [22] := '';
   str_camp_obj [23] := '- Destroy all bases and armies of hell';  }


   str_makeHints;
end;

procedure lng_rus;
var t: shortstring;
    i: byte;
begin
  str_Caption_Map               := 'КАРТА';
  str_Caption_Players           := 'ИГРОКИ';
  str_Caption_Multiplayer       := 'СЕТЕВАЯ ИГРА';
  str_Caption_GOptions          := 'ПАРАМЕТРЫ ИГРЫ';
  str_MObjectives               := 'ЗАДАЧИ';

  str_menu_Tutorials            := 'ОБУЧЕНИЕ';
  str_menu_Campaings            := 'КАМПАНИИ';
  str_menu_Scirmish             := 'СХВАТКА';
  str_menu_Playback             := 'ПРОСМОТР ЗАПИСИ';
  str_menu_SaveLoad             := 'СОХР./ЗАГР.';
  str_menu_LoadGame             := 'ЗАГРУЗИТЬ ИГРУ';
  str_menu_Replays              := 'ЗАПИСИ';
  str_menu_Settings             := 'НАСТРОЙКИ';

  str_menu_Start                := 'НАЧАТЬ';
  str_menu_Surrender            := 'СДАТЬСЯ';
  str_menu_Break                := 'ПРЕРВАТЬ МИССИЮ';
  str_menu_PlaybackStop         := 'ПРЕРВАТЬ';
  str_menu_Exit                 := 'ВЫХОД';
  str_menu_Back                 := 'НАЗАД';

  str_menu_SetGame      := 'ИГРА';
  str_menu_SetReplay    := 'ЗАПИСЬ ИГРЫ';
  str_menu_SetVideo     := 'ГРАФИКА';
  str_menu_SetSound     := 'ЗВУК';

  str_SR_RecordGames    := 'Записывать игры';
  str_SR_ReplayPrefix   := 'Префикс записи';
  str_SR_Quality        := 'Размер/качество';

  str_FileInfo          := 'ИНФОРМАЦИЯ';
  str_FileSave          := 'Сохранить';
  str_FileLoad          := 'Загрузить';
  str_FileDelete        := 'Удалить';

  str_map               := 'Карта';
  str_map_Seed          := 'Номер';
  str_map_Size          := 'Размер';
  str_map_Obstacles     := 'Преграды';
  str_map_Symmetry      := 'Симметрия';
  str_map_Random        := 'Случайная карта';

  str_map_Scenario              := 'Сценарий';
  str_map_ScenarioL[mc_scirmish]:= tc_lime  +'Схватка'          +tc_default;
  str_map_ScenarioL[mc_3x3     ]:= tc_orange+'3x3'              +tc_default;
  str_map_ScenarioL[mc_2x2x2   ]:= tc_yellow+'2x2x2'            +tc_default;
  str_map_ScenarioL[mc_capture ]:= tc_aqua  +'Захват точек'     +tc_default;
  str_map_ScenarioL[mc_invasion]:= tc_blue  +'Вторжение'        +tc_default;
  str_map_ScenarioL[mc_KotH    ]:= tc_purple+'Царь горы'        +tc_default;
  str_map_ScenarioL[mc_royale  ]:= tc_red   +'Королевская битва'+tc_default;

  str_map_Generators            := 'Генераторы';
  str_map_GeneratorsL[0]        := 'свои';
  str_map_GeneratorsL[1]        := '5 мин.';
  str_map_GeneratorsL[2]        := '10 мин.';
  str_map_GeneratorsL[3]        := '15 мин.';
  str_map_GeneratorsL[4]        := '20 мин.';
  str_map_GeneratorsL[5]        := 'вечные';

  str_Players           := 'Игроки';

  str_SS_MusicVolume          := 'Громкость музыки';
  str_SS_SoundVolume          := 'Громкость звуков';
  str_SG_PlayerName           := 'Имя игрока';
  str_SG_RightClickAct        := 'Действие на правый клик';
  str_SG_RightClickActL[true ]:= tc_lime+'движение'+tc_default;
  str_SG_RightClickActL[false]:= tc_lime+'движ.'   +tc_default+'+'+tc_red+'атака'+tc_default;
  str_SG_ScrollSpeed          := 'Скорость пр.';
  str_SG_MouseScroll          := 'Прокр. мышью';
  str_SG_Language       := 'Язык интерфейса';

  str_SV_ResolutionApply:= 'Применить разрешение';
  str_SV_ResolutionW    := 'Разрешение (ширина)';
  str_SV_ResolutionH    := 'Разрешение (высота)';
  str_SV_Windowed       := 'В окне:';

  str_race[r_random]    := tc_white+'ЛЮБАЯ'  +tc_default;
  str_observer          := 'ЗРИТЕЛЬ';
  str_pause             := 'Пауза';
  str_win               := 'ПОБЕДА!';
  str_lose              := 'ПОРАЖЕНИЕ!';
  str_gsunknown         := 'Неизвестный статус!';
  str_gsaved            := 'Игра сохранена';
  str_repend            := 'Конец записи!';
  str_reperror          := 'Ошибка при чтении файла!';

  str_FileError_NExists  := 'Файл не'+tc_nl3+'существует!';
  str_FileError_Open  := 'Неполучилось'+tc_nl3+'открыть файл!';
  str_FileError_WData := 'Неправильные'+tc_nl3+'данные файла!';
  str_FileError_WVer  := 'Неправильная'+tc_nl3+'версия файла!';
  str_time              := 'Время: ';
  str_menu              := 'Меню';
  str_PlayerDefeat        := ' уничтожен!';
  str_inv_time          := 'Волна #';
  str_inv_ml            := 'Армия монстров: ';
  str_ReplayPlay              := 'Проиграть';

  str_Camp_Difficulty            := 'Сложность';
  str_WaitForServer            := 'Ожидание сервера...';

  str_Caption_Server            := 'СЕРВЕР';
  str_Caption_Client            := 'КЛИЕНТ';
  str_menu_chat         := 'ЧАТ(ВСЕ ИГРОКИ)';
  str_chat_all          := 'ВСЕ:';
  str_chat_allies       := 'СОЮЗНИКИ:';
  str_GO_Random           := 'Случайная схватка';

  str_PlayerLeft             := ' покинул игру';
  str_PlayerSurrender  := ' сдается!';
  str_GO_AISlots           := 'Заполнить пустые слоты';



  str_requirements      := 'Требования: ';
  str_req               := 'Треб.: ';
  str_orders            := 'Отряды: ';
  str_all               := 'Все';
  str_uprod             := tc_lime+'Создается в: '+tc_default;
  str_bprod             := tc_lime+'Чем может быть построен: '     +tc_default;
  str_SG_ColoredShadow  := 'Цветные тени';
  str_kothtime          := 'Время до захвата центра: ';
  str_kothtime_act      := 'Время до активации центральной зоны: ';
  str_kothwinner        := ' - Царь Горы!';
  str_GO_DefeatedObs     := 'Наблюдатель после поражения';
  str_SV_MenuScale        := 'Растягивание меню';
  str_SV_MenuScaleSmooth       := 'Гладкое растянутое меню';
  str_SV_ShowFPS               := 'Показать FPS';
  str_SG_ShowAPM               := 'Показать APM';
  str_ability           := 'Специальная способность: ';
  str_transformation    := 'превращение в ';
  str_upgradeslvl       := 'Улучшения: ';
  str_demons            := 'демоны и зомби';
  str_except            := 'кроме';
  str_splashresist      := 'Невосприимчив к взрывной волне';
  str_TargetLimit       := 'лимит цели';
  str_SS_NextTrack         := 'Следующий трек';
  str_SS_ReloadMusic       := 'Загрузить новый плейлист';
  str_PlayerPaused      := 'игрок приостановил игру';
  str_PlayerResumed     := 'игрок возобновил игру';
  str_SS_MusicListSize     := 'Размер плейлиста';
  str_menu_controls     := '- используйте левую и правую кнопки мыши для управления пунктами меню -';
  str_RecordingStart    := 'Начало записи: ';
  str_RecordingStop     := 'Остановка записи: ';
  str_PT_Player          := 'ИГРОК';
  str_PT_State           := 'СТАТУС';
  str_PT_Race            := 'РАСА';
  str_PT_Team            := 'КЛАН';
  str_PT_Color           := 'ЦВЕТ';
  str_PT_Ping            := 'ПИНГ+';

  str_builder           := 'Строитель';
  str_barrack           := 'Производит юнитов';
  str_smith             := 'Исследует улучшения и апгрейды';
  str_IncEnergyLevel    := 'Увеличивает уровень энергии';
  str_CanRebuildTo      := 'Можно перестроить в ';
  str_UnitArming        := 'Вооружение/Способности: ';
  str_hits              := 'Здоровье: ';
  str_srange            := 'Базовый радиус обзора: ';

  str_weapon_melee      := 'ближний бой';
  str_weapon_ranged     := 'дальний бой';
  str_weapon_zombie     := '+зомбификация';
  str_weapon_ressurect  := 'воскрешение';
  str_weapon_heal       := 'лечение/ремонт';
  str_weapon_spawn      := 'порождение';
  str_weapon_suicide    := 'самоубийство';
  str_weapon_targets    := 'цели: ';
  str_weapon_damage     := 'воздействие';

  str_cant_land         := 'Нельзя переместиться или приземлиться здесь';
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
  str_cpoint_captured   := 'Ключевая точка захвачена!';
  str_cpoint_lost       := 'Ключевая точка потеряна!';
  str_koth_control      := ' команда контролирует центр!';
  str_ngen_captured     := 'Нейтральный генератор захвачен!';
  str_ngen_lost         := 'Нейтральный генератор потерян!';
  str_ngen_exh          := 'Нейтральный генератор истощился!';
  str_invalid_target    := 'Не подходящая цель!';

  str_attr_alive        := tc_lime  +'живой'         ;
  str_attr_dead         := tc_dgray +'мертвый'       ;
  str_attr_unit         := tc_gray  +'юнит'          ;
  str_attr_building     := tc_red   +'здание'        ;
  str_attr_mech         := tc_blue  +'механический'  ;
  str_attr_bio          := tc_orange+'биологический' ;
  str_attr_light        := tc_yellow+'легкий'        ;
  str_attr_heavy        := tc_green +'тяжелый'       ;
  str_attr_fly          := tc_white +'летающий'      ;
  str_attr_ground       := tc_lime  +'наземный'      ;
  str_attr_floater      := tc_aqua  +'парящий'       ;
  str_attr_level        := tc_white +'уровень '      ;
  str_attr_invuln       := tc_lime  +'неуязвимый'    ;
  str_attr_stuned       := tc_yellow+'оглушен'       ;
  str_attr_detector     := tc_purple+'детектор'      ;
  str_attr_transport    := tc_gray  +'транспорт'     ;

  str_SG_ControlPanelPos          := 'Положение игровой панели';
  str_SG_ControlPanelPosL[0]      := tc_lime  +'слева' +tc_default;
  str_SG_ControlPanelPosL[1]      := tc_orange+'справа'+tc_default;
  str_SG_ControlPanelPosL[2]      := tc_yellow+'вверху'+tc_default;
  str_SG_ControlPanelPosL[3]      := tc_aqua  +'внизу' +tc_default;

  str_SG_HealthBars             := 'Полоски здоровья';
  str_SG_HealthBarsL[0]         := tc_lime  +'выбранные'+tc_default+'+'+tc_red+'поврежд.'+tc_default;
  str_SG_HealthBarsL[1]         := tc_aqua  +'всегда'   +tc_default;
  str_SG_HealthBarsL[2]         := tc_orange+'только '  +tc_lime+'выбранные'+tc_default;

  str_SG_PlayersColor            := 'Цвета игроков';
  str_SG_PlayersColorL[0]        := tc_white +'по умолчанию'+tc_default;
  str_SG_PlayersColorL[1]        := tc_lime  +'свои '+tc_yellow+'союзники '+tc_red+'враги'+tc_default;
  str_SG_PlayersColorL[2]        := tc_white +'свои '+tc_yellow+'союзники '+tc_red+'враги'+tc_default;
  str_SG_PlayersColorL[3]        := tc_white +'свои '+tc_aqua  +'союзники '+tc_red+'враги'+tc_default;
  str_SG_PlayersColorL[4]        := tc_purple+'команды'+tc_default;
  str_SG_PlayersColorL[5]        := tc_white +'свои '+tc_purple+'команды'+tc_default;

  str_GO_FixedStarts            := 'Фиксированные старты';

  str_net_Ready             := 'Готов';
  str_net_UDPPort           := 'UDP порт';
  str_net_ServerStart       := 'Включить сервер';
  str_net_ServerStop        := 'Выключить сервер';
  str_net_Connect           := 'Подключится';
  str_net_Disconnect        := 'Отключится';
  str_net_Quality           := 'Обновление юнитов';
  str_net_Address           := 'Адрес';
  str_net_LANSearch         := 'Поиск серверов в LAN';

  str_connecting        := 'Соединение...';
  str_portblocked       := 'Порт занят!';
  str_msg_WrongVersion              := 'Другая версия!';
  str_msg_ServerFull             := 'Нет мест!';
  str_msg_GameStarted              := 'Игра началась!';

  str_hint_Tab[0]         := 'Здания';
  str_hint_Tab[1]         := 'Юниты';
  str_hint_Tab[2]         := 'Исследования';
  str_hint_Tab[3]         := 'Запись';

  str_hint_m[0]         := 'Меню (' +tc_lime+'Esc'        +tc_default+')';
  str_hint_m[2]         := 'Пауза ('+tc_lime+'Pause/Break'+tc_default+')';

  str_hint_army         := 'Армия: ';
  str_hint_energy       := 'Энергия: ';

  str_ability_name[uab_Teleport        ]:='Призыв';
  str_ability_name[uab_UACScan         ]:='Сканирование';
  str_ability_name[uab_HTowerBlink     ]:='Скачок';
  str_ability_name[uab_UACStrike       ]:='Ракетный удар';
  str_ability_name[uab_HKeepBlink      ]:='Перемещение';
  str_ability_name[uab_RebuildInPoint  ]:='';
  str_ability_name[uab_HInvulnerability]:='Неуязвимость';
  str_ability_name[uab_SpawnLost       ]:='Выпустить Lost Soul';
  str_ability_name[uab_HellVision      ]:='Адское зрение';
  str_ability_name[uab_CCFly           ]:='Двигатели для полета';
  str_ability_name[uab_ToUACDron       ]:='Разобрать в Дрона';
  str_ability_name[uab_Unload          ]:='Выгрузить';
  str_ability_reloading:='Способность перезаряжается!';

  _mkHStrUid(UID_HKeep           ,'Адская Крепость'            ,'');
  _mkHStrUid(UID_HAKeep          ,'Великая Адская Крепость'    ,'');
  _mkHStrUid(UID_HGate           ,'Врата Демонов'              ,'');
  _mkHStrUid(UID_HSymbol1        ,'Нечестивый Символ ур.1'     ,'');
  _mkHStrUid(UID_HSymbol2        ,'Нечестивый Символ ур.2'     ,'');
  _mkHStrUid(UID_HSymbol3        ,'Нечестивый Символ ур.3'     ,'');
  _mkHStrUid(UID_HSymbol4        ,'Нечестивый Символ ур.4'     ,'');
  _mkHStrUid(UID_HPools          ,'Инфернальные Омуты'         ,'');
  _mkHStrUid(UID_HTeleport       ,'Телепорт'                   ,'Базовая перезарядка телепортации - '+tc_aqua+i2s(hteleport_rldPerLimit)+tc_default+'*[лимит перемещаемого юнита]');
  _mkHStrUid(UID_HPentagram      ,'Пентаграмма Смерти'         ,'');
  _mkHStrUid(UID_HMonastery      ,'Монастырь Отчаяния'         ,'');
  _mkHStrUid(UID_HFortress       ,'Замок Проклятых'            ,'');
  _mkHStrUid(UID_HTower          ,'Сторожевая Башня'           ,'Базовое защитное сооружение'          );
  _mkHStrUid(UID_HTotem          ,'Тотем Ужаса'                ,'Продвинутое защитное сооружение'      );
  _mkHStrUid(UID_HAltar          ,'Алтарь Боли'                ,'Длительность эффекта "'+str_ability_name[uab_HInvulnerability]+'" - '+i2s(invuln_time_sec)+' сек., перезарядка способности - '+tc_aqua+i2s(haltar_reload_sec)+tc_default+' сек');
  _mkHStrUid(UID_HCommandCenter  ,'Проклятый Командный Центр'  ,''          );
  _mkHStrUid(UID_HACommandCenter ,'Продвинутый Проклятый Командный Центр','');
  _mkHStrUid(UID_HBarracks       ,'Казармы Зомби'              ,''          );
  _mkHStrUid(UID_HEyeNest        ,'Гнездо Ока Зла'             ,'Обнаружение невидимых войск. Перезарядка способности - '+tc_aqua+i2s(hell_vision_reload_sec)+tc_default+' сек');

  _mkHStrUid(UID_ZMedic          ,'Зомби Медик'                ,'');
  _mkHStrUid(UID_ZEngineer       ,'Зомби Инженер'              ,'');
  _mkHStrUid(UID_ZSergant        ,'Зомби Сержант'              ,'');
  _mkHStrUid(UID_ZSSergant       ,'Зомби Старший Сержант'      ,'');
  _mkHStrUid(UID_ZCommando       ,'Зомби Коммандо'             ,'');
  _mkHStrUid(UID_ZAntiaircrafter ,'Зомби Зенитчик'             ,'');
  _mkHStrUid(UID_ZSiegeMarine    ,'Зомби Артиллерист'          ,'');
  _mkHStrUid(UID_ZFPlasmagunner  ,'Зомби Плазмаганнер'         ,'');
  _mkHStrUid(UID_ZBFGMarine      ,'Зомби Солдат с BFG'         ,'');

  _mkHStrUpid(upgr_hell_t1attack  ,'Адская Огневая Мощь'           ,'Увеличение урона от дальних атак всех Т1 юнитов и защитных сооружений');
  _mkHStrUpid(upgr_hell_uarmor    ,'Боевая Плоть'                  ,'Увеличение защиты всех адских юнитов'                                 );
  _mkHStrUpid(upgr_hell_barmor    ,'Каменные Стены'                ,'Увеличение защиты всех адских зданий'                                 );
  _mkHStrUpid(upgr_hell_mattack   ,'Когти и зубы'                  ,'Увеличение урона от ближних атак'                                     );
  _mkHStrUpid(upgr_hell_regen     ,'Регенерация Плоти'             ,'Восстановление здоровья всех адских юнитов'                           );
  _mkHStrUpid(upgr_hell_pains     ,'Болевой Порог'                 ,'Адские юниты реже испытывают болевой паралич'                         );
  _mkHStrUpid(upgr_hell_towers    ,'Демоническое Чутье'            ,'Увеличение радиуса обзора и атаки для защитных сооружений'            );
  _mkHStrUpid(upgr_hell_HKTeleport,'Телепортация Адской Крепости'  ,'Заряд для способности Адской Крепости'                                );
  _mkHStrUpid(upgr_hell_paina     ,'Аура Разложения'               ,'Адская крепость наносит урон всем вражеских не-зданиям вокруг. Урон игнорирует броню юнитов');
  _mkHStrUpid(upgr_hell_buildr    ,'Увеличение Области Обзора Адской Крепости',''                                       );

  _mkHStrUpid(upgr_hell_spectre   ,'Призраки'                      ,'Pinky Demon становиться невидимым'                                         );
  _mkHStrUpid(upgr_hell_vision    ,'Адское Зрение'                 ,'Увеличение области обзора и атаки всех адских юнитов'                      );
  _mkHStrUpid(upgr_hell_phantoms  ,'Фантомы'                       ,'Pain Elemental создает Фантомов вместо Lost Soul'                          );
  _mkHStrUpid(upgr_hell_t2attack  ,'Демоническое Оружие'           ,'Увеличение урона от дальних атак всех Т2 юнитов и защитных сооружений'     );
  _mkHStrUpid(upgr_hell_teleport  ,'Улучшение Телепорта'           ,'Уменьшение времени перезарядки Телепорта'                              );
  _mkHStrUpid(upgr_hell_rteleport ,'Призыв'                        ,'Юнитов можно перемещать обратно в Телепорт'                            );
  _mkHStrUpid(upgr_hell_heye      ,'Улучшение Ока Зла'             ,'Увеличение области обзора Ока Зла'                           );
  _mkHStrUpid(upgr_hell_totminv   ,'Невидимость Тотема Ужаса'      ,''                               );
  _mkHStrUpid(upgr_hell_bldrep    ,'Восстановление Зданий'         ,'Восстановление здоровья всех адских зданий'                   );
  _mkHStrUpid(upgr_hell_tblink    ,'Короткая Телепортация'         ,'Заряды для способности Сторожевой Башни и Тотема Ужаса');
  _mkHStrUpid(upgr_hell_resurrect ,'Воскрешение'                   ,'Способность ArchVile'                    );


  _mkHStrUid(UID_UCommandCenter  ,'Командный Центр'            ,'');
  _mkHStrUid(UID_UACommandCenter ,'Продвинутый Командный Центр','');
  _mkHStrUid(UID_UBarracks       ,'Казармы'                    ,'');
  _mkHStrUid(UID_UFactory        ,'Фабрика'                    ,'');
  _mkHStrUid(UID_UGenerator1     ,'Генератор ур.1'             ,'');
  _mkHStrUid(UID_UGenerator2     ,'Генератор ур.2'             ,'');
  _mkHStrUid(UID_UGenerator3     ,'Генератор ур.3'             ,'');
  _mkHStrUid(UID_UGenerator4     ,'Генератор ур.4'             ,'');
  _mkHStrUid(UID_UWeaponFactory  ,'Завод Вооружений'           ,'');
  _mkHStrUid(UID_UGTurret        ,'Анти-наземная Турель'       ,'Анти-наземное защитное сооружение' );
  _mkHStrUid(UID_UATurret        ,'Анти-воздушная Турель'      ,'Анти-воздушное защитное сооружение');
  _mkHStrUid(UID_UTechCenter     ,'Научный Центр'              ,'');
  _mkHStrUid(UID_UComputerStation,'Компьютерная Станция'       ,'');
  _mkHStrUid(UID_URadar          ,'Радар'                      ,'Разведует карту. Перезарядка способности - '+tc_aqua+i2s(radar_reload_sec)+tc_default+' сек');
  _mkHStrUid(UID_URMStation      ,'Станция Ракетного Залпа'    ,'Урон "'+str_ability_name[uab_UACStrike]+'" - '+tc_red+i2s(g_mids[MID_Blizzard].mid_base_damage)+tc_default+': ' +str_DamageHint(dm_RSMShot)+', перезарядка способности '+tc_aqua+i2s(mstrike_reload_sec)+tc_default+' сек');
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


  _mkHStrUpid(upgr_uac_attack     ,'Улучшение Воружений'               ,'Увеличение урона от дальних атак всех юнитов и защитных сооружений');
  _mkHStrUpid(upgr_uac_uarmor     ,'Улучшение Пехотной Брони'          ,'Увеличение защиты всех юнитов из Казарм'                     );
  _mkHStrUpid(upgr_uac_barmor     ,'Бетонные Стены'                    ,'Увеличение защиты всех зданий'                               );
  _mkHStrUpid(upgr_uac_melee      ,'Продвинутые Инструменты'           ,'Увеличение эффективности ремонта Инженера и лечения Медика'  );
  _mkHStrUpid(upgr_uac_mspeed     ,'Легковесная Броня'                 ,'Увеличение скорости передвижения всех юнитов из Казарм'      );
  _mkHStrUpid(upgr_uac_ssgup      ,'Разрывные Пули'                    ,'Атака Сержанта, Старшего Сержанта и Терминатора чаще вызывают pain state' );
  _mkHStrUpid(upgr_uac_towers     ,'Прожекторы'                        ,'Увеличение радиуса обзора и атаки для защитных сооружений'      );
  _mkHStrUpid(upgr_uac_CCFly      ,'Летные Двигатели Командного Центра','Командный Центр может летать'                                   );
  _mkHStrUpid(upgr_uac_ccturr     ,'Турель Командного Центра'          ,'Командный Центр может атаковать'                                );
  _mkHStrUpid(upgr_uac_buildr     ,'Увеличение Области Обзора Командного Центра',''                           );

  _mkHStrUpid(upgr_uac_botturret  ,'Протокол Трансформации Дрона'      ,'Дрон может превратиться в Анти-наземную Турель'    );
  _mkHStrUpid(upgr_uac_vision     ,'Улучшенные Визоры'                 ,'Увеличение области обзора и атаки всех юнитов'  );
  _mkHStrUpid(upgr_uac_commando   ,'Стелс-Технологии'                  ,'Коммандо становиться невидимым'                 );
  _mkHStrUpid(upgr_uac_airsp      ,'Осколочные Снаряды'                ,'Антивоздушные снаряды наносят урон по области'  );
  _mkHStrUpid(upgr_uac_mechspd    ,'Улучшеные Двигатели'               ,'Увеличение скорости передвижения юнитов из Фабрики'      );
  _mkHStrUpid(upgr_uac_mecharm    ,'Улучшение Технической Брони'       ,'Увеличение защиты всех юнитов из Фабрики'                );
  _mkHStrUpid(upgr_uac_antiair    ,'Анти-воздушное Орудие'             ,'Анти-воздушное оружие для Терминатора'                   );
  _mkHStrUpid(upgr_uac_transport  ,'Улучшение Транспорта'              ,'Увеличение вместимости Десантного Корабля'               );
  _mkHStrUpid(upgr_uac_radar_r    ,'Улучшение Радара'                  ,'Увеличение области обзора Радара'            );
  _mkHStrUpid(upgr_uac_plasmt     ,'Анти-наземное Плазменное Орудие'   ,'Анти-['+str_attr_mech+'] орудие для Анти-наземной Турели');
  _mkHStrUpid(upgr_uac_turarm     ,'Дополнительное Бронирование'       ,'Дополнительная защита для турелей'              );

  {str_sability := 'Специальная способность';
  str_spability:= 'Специальная способность в точке';

  str_use_sability :='Используйте приказ "'+str_sability +'"!';
  str_use_spability:='Используйте приказ "'+str_spability+'"!'; }

  //_mkHStrACT(0 ,str_sability );
  //_mkHStrACT(1 ,str_spability);
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
  _mkHStrACT(13,str_SG_RightClickAct           );

  _mkHStrRPL(0 ,'Включить/выключить ускоренный просмотр',false);
  _mkHStrRPL(1 ,'Левый клик: назад на 2 секунды ('                                 +tc_lime+'W'+tc_default+')'+tc_nl1+
                'Правый клик: назад на 10 секунд ('  +tc_lime+'Ctrl'+tc_default+'+'+tc_lime+'W'+tc_default+')'+tc_nl1+
                'Средний клик: назад на 1 минуту ('  +tc_lime+'Alt' +tc_default+'+'+tc_lime+'W'+tc_default+')',true  );
  _mkHStrRPL(2 ,'Левый клик: пропустить 2 секунды ('                               +tc_lime+'E'+tc_default+')'+tc_nl1+
                'Правый клик: пропустить 10 секунд ('+tc_lime+'Ctrl'+tc_default+'+'+tc_lime+'E'+tc_default+')'+tc_nl1+
                'Средний клик: пропустить 1 минуту ('+tc_lime+'Alt' +tc_default+'+'+tc_lime+'E'+tc_default+')',true  );
  _mkHStrRPL(3 ,'Пауза'                   ,false);
  _mkHStrRPL(4 ,'Камера игрока'           ,false);
  _mkHStrRPL(5 ,'Список игровых сообщений',false);
  _mkHStrRPL(6 ,'Туман войны'             ,false);
  _mkHStrRPL(8 ,'Все игроки'              ,false);
  _mkHStrRPL(9 ,'Игрок #1',false);
  _mkHStrRPL(10,'Игрок #2',false);
  _mkHStrRPL(11,'Игрок #3',false);
  _mkHStrRPL(12,'Игрок #4',false);
  _mkHStrRPL(13,'Игрок #5',false);
  _mkHStrRPL(14,'Игрок #6',false);

  _mkHStrOBS(0 ,'Туман войны',false);
  _mkHStrOBS(2 ,'Все игроки' ,false);
  _mkHStrOBS(3 ,'Игрок #1'   ,false);
  _mkHStrOBS(4 ,'Игрок #2'   ,false);
  _mkHStrOBS(5 ,'Игрок #3'   ,false);
  _mkHStrOBS(6 ,'Игрок #4'   ,false);
  _mkHStrOBS(7 ,'Игрок #5'   ,false);
  _mkHStrOBS(8 ,'Игрок #6'   ,false);


  FillChar(str_menu_hint,sizeOf(str_menu_hint),0);

  //for i in byte do str_menu_hint[i]:=b2s(i);

  /////////////////////////////////////////////////////////////////////////////


  str_cmp_unk       := 'НЕИЗВЕСТНО';
  str_cmp_Date      := tc_gray+'Дата: ' +tc_default;
  str_cmp_Location  := tc_gray+'Место: '+tc_default;
  str_cmp_Area      := tc_gray+'Район: '+tc_default;

  for i:=0 to LastMission do
  begin
     setlength(str_camp_infol[i],0);
     str_camp_infon[i]:=0;
  end;


  cmp_AddPlot(0,false,
'Эта планета выглядит устрашающе: повсюду огонь, раскаленная лава и жуткие существа. Она находится далеко среди тысяч других миров, принадлежащих могущественной галактической империи. Здесь все оставалось неизменным долгие столетия после завоевания...');
  cmp_AddPlot(0,false,
'пока вдруг не заработал старый телепортатор, построенный какой-то древней цивилизацией. Из портала прибыли технически развитые пришельцы, сразу занявшиеся изучением новой местности.');

  cmp_AddPlot(0,true ,
'Вы - один из высших демонов, чье призвание - вести в бой демоническое воинство. Вы не так давно были повышены до своего нынешнего ранга и еще не успели проявить себя.');
  cmp_AddPlot(0,false,
'Ваше первое задание - изучить пришельцев, проникнуть в их мир и подчинить его власти Империи.');

  cmp_AddPlot(0,true,
'Захватчики построили крупный лагерь около Портала, а у нас в этом регионе нет даже небольшого форпоста. Необходимо быстро построить базу, призвать армию и сокрушить нарушителей!');

  cmp_AddPlot(0,true ,'- Достичь уровня энергии 2000');
  cmp_AddPlot(0,false,'- Построить 4 Врат Демонов'  );
  cmp_AddPlot(0,false,'- Призвать 30 адских монстров');
  cmp_AddPlot(0,false,'- Адская Крепость должна уцелеть' );
  cmp_AddPlot(0,false,'- Уничтожить вторгшихся захватчиков');

  {str_camp_MissionName[0]         := 'Hell #1: Вторжение на Фобос';
  str_camp_MissionName[1]         := 'Hell #2: Военная база';
  str_camp_MissionName[2]         := 'Hell #3: Вторжение на Деймос';
  str_camp_MissionName[3]         := 'Hell #4: Пентаграмма смерти';
  str_camp_MissionName[4]         := 'Hell #7: Каньон';
  str_camp_MissionName[5]         := 'Hell #8: Ад на Марсе';
  str_camp_MissionName[6]         := 'Hell #5: Ад на Земле';
  str_camp_MissionName[7]         := 'Hell #6: Космодром';

  str_camp_obj[0]         := '-Уничтожь все людские базы и армии'+tc_nl3+'-Защити портал';
  str_camp_obj[1]         := '-Уничтожь военную базу';
  str_camp_obj[2]         := '-Уничтожь все людские базы и армии'+tc_nl3+'-Защити портал';
  str_camp_obj[3]         := '-Защити алтари в течении 20 минут';
  str_camp_obj[4]         := '-Уничтожь все людские базы и армии';
  str_camp_obj[5]         := '-Уничтожь все людские базы и армии';
  str_camp_obj[6]         := '-Уничтожь все людские базы и армии';
  str_camp_obj[7]         := '-Уничтожь космодром'+tc_nl3+'-Ни один людской транспорт не должен'+tc_nl3+'уйти';

  str_camp_map[0]         := tc_lime+'Дата:'+tc_default+tc_nl2+'15.11.2145'+tc_nl2+tc_lime+'Место:'+tc_default+tc_nl2+'ФОБОС' +tc_nl2+tc_lime+'Район:'+tc_default+tc_nl2+'Аномалия';
  str_camp_map[1]         := tc_lime+'Дата:'+tc_default+tc_nl2+'16.11.2145'+tc_nl2+tc_lime+'Место:'+tc_default+tc_nl2+'ФОБОС' +tc_nl2+tc_lime+'Район:'+tc_default+tc_nl2+'Кратер Халл';
  str_camp_map[2]         := tc_lime+'Дата:'+tc_default+tc_nl2+'15.11.2145'+tc_nl2+tc_lime+'Место:'+tc_default+tc_nl2+'ДЕЙМОС'+tc_nl2+tc_lime+'Район:'+tc_default+tc_nl2+'Аномалия';
  str_camp_map[3]         := tc_lime+'Дата:'+tc_default+tc_nl2+'16.11.2145'+tc_nl2+tc_lime+'Место:'+tc_default+tc_nl2+'ДЕЙМОС'+tc_nl2+tc_lime+'Район:'+tc_default+tc_nl2+'Кратер Свифт';
  str_camp_map[4]         := tc_lime+'Дата:'+tc_default+tc_nl2+'18.11.2145'+tc_nl2+tc_lime+'Место:'+tc_default+tc_nl2+'МАРС'  +tc_nl2+tc_lime+'Район:'+tc_default+tc_nl2+'Равнина Хеллас';
  str_camp_map[5]         := tc_lime+'Дата:'+tc_default+tc_nl2+'19.11.2145'+tc_nl2+tc_lime+'Место:'+tc_default+tc_nl2+'МАРС'  +tc_nl2+tc_lime+'Район:'+tc_default+tc_nl2+'Равнина Хеллас';
  str_camp_map[6]         := tc_lime+'Дата:'+tc_default+tc_nl2+'18.11.2145'+tc_nl2+tc_lime+'Место:'+tc_default+tc_nl2+'ЗЕМЛЯ' +tc_nl2+tc_lime+'Район:'+tc_default+tc_nl2+'Неизвестно';
  str_camp_map[7]         := tc_lime+'Дата:'+tc_default+tc_nl2+'19.11.2145'+tc_nl2+tc_lime+'Место:'+tc_default+tc_nl2+'ЗЕМЛЯ' +tc_nl2+tc_lime+'Район:'+tc_default+tc_nl2+'Неизвестно';  }

  str_makeHints;
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

        writeln(f,'Hotkey: ',RemoveSpecChars(HotKeyBase2Str(_ucl)));
        writeln(f,'Categories/Attributes: ',RemoveSpecChars(str_UnitAttributes(nil,u)));
        writeln(f,'Max hits: ',_mhits);
        //if(_base_armor>0)then
        //writeln(f,'Base armor: ',_base_armor);
        if(_baseregen>0)then
        writeln(f,'Base regeneration: ',_baseregen);
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
        writeln(f,'Places in transport: ',_transportS );
        if(_transportM>0)then
        writeln(f,'Base transport capacity: ',_transportM );

        if(_zombie_uid>0)then
        if(_zombie_hits>0)or(_fastdeath_hits<0)then
        begin
        writeln(f,'Zombie: ',g_uids[_zombie_uid].un_txt_name );
        writeln(f,'Zombification hits: ',_zombie_hits);
        end;

        writeln(f,RemoveSpecChars(un_txt_uihint4));

        if(_attack=atm_always)then
        begin
           writeln(f,str_UnitArming);
           for w:=0 to MaxUnitWeapons do
            with _a_weap[w] do
            begin
               tmp:=str_MakeWeaponString(u,w,true);
               if(length(tmp)>0)then writeln(f,tmp,';');
            end;
        end;


        writeln(f,'Upgrades:');
        upgrLine(_upgr_srange,'vision range '+i2sSign(_upgr_srange_step));
        if(not _ukbuilding)then
        upgrLine(upgr_race_unit_srange[_urace],'vision range '+i2sSign(upgr_race_srange_unit_bonus[_urace]));

        if(_ukbuilding)
        then upgrLine(_upgr_armor,'armor '+i2sSign(UpgradeBuildArmorBonus))
        else upgrLine(_upgr_armor,'armor '+i2sSign(UpgradeUnitArmorBonus ));

        if(_ukbuilding)
        then upgrLine(upgr_race_armor_build[_urace],'armor '+i2sSign(UpgradeBuildArmorBonus))
        else
          if(_ukmech)
          then upgrLine(upgr_race_armor_mech[_urace],'armor '+i2sSign(UpgradeUnitArmorBonus))
          else upgrLine(upgr_race_armor_bio [_urace],'armor '+i2sSign(UpgradeUnitArmorBonus));

        upgrLine(_upgr_regen,'hits regeneration '+i2sSign(BaseArmorBonus1));
        if(_ukbuilding)
        then upgrLine(upgr_race_regen_build[_urace],'hits regeneration '+i2sSign(BaseArmorBonus1))
        else
          if(_ukmech)
          then upgrLine(upgr_race_regen_mech[_urace],'hits regeneration '+i2sSign(BaseArmorBonus1))
          else upgrLine(upgr_race_regen_bio [_urace],'hits regeneration '+i2sSign(BaseArmorBonus1));

        if(_ukbuilding)
        then
        else
          if(_ukmech)
          then upgrLine(upgr_race_mspeed_mech[_urace],'movement speed '+i2sSign(2))
          else upgrLine(upgr_race_mspeed_bio [_urace],'movement speed '+i2sSign(2));

        if(not _ukbuilding)and(_painc>0)and(_urace=r_hell)then
        upgrLine(upgr_hell_pains,'PainState threshold '+i2sSign(_painc_upgr_step));

        writeln(f);

        writeln(f,RemoveSpecChars(str_MakeUnitDefaultDescription(u,un_txt_udescr,true)));

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
        writeln(f,RemoveSpecChars(str_makeUpgrBaseHint(u,255)));
        writeln(f,RemoveSpecChars(_up_hint));
        writeln(f);
     end;
   writeln(f);
{
s1:=str_makeUpgrBaseHint(uid,upgr[uid]+1);
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



