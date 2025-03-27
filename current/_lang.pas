
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
   25 : l2s:=i2s(limit div base)+'.25';
   50 : l2s:=i2s(limit div base)+'.5';
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
   else               GetKeyName:=UpperCase(SDL_GetKeyName(k));
   end
end;

function hotKeyCommon(ucl:byte;phkt1,phkt2:pTHotKeyTable):shortstring;
begin
   hotKeyCommon:='';
   if(ucl<=HotKeysArraySize)then
     if(phkt1^[ucl]>0)then
     begin
        if(phkt2^[ucl]>0)then
        hotKeyCommon:=tc_lime+GetKeyName(phkt2^[ucl])+tc_default+'+';
        hotKeyCommon+=tc_lime+GetKeyName(phkt1^[ucl])+tc_default;
     end;
end;


procedure SetHintStr(ucl:byte;pHintTable:pTPanelHintTable;phkt1,phkt2:pTHotKeyTable;noHK:boolean;hint:shortstring);
var hk:shortstring;
begin
   if(ucl<=HotKeysArraySize)then
   begin
      if(noHK)
      then hk:=''
      else hk:=hotKeyCommon(ucl,phkt1,phkt2);
      if(length(hk)>0)
      then pHintTable^[ucl]:=hint+' ('+hk+')'
      else pHintTable^[ucl]:=hint;
   end;
end;

procedure SetStrUAbility(aid:byte;NAME,DESCR:shortstring);
begin
   with g_uability[aid] do
   begin
      ua_name :=NAME;
      ua_descr:=DESCR;
   end;
end;

procedure hintStrUID(uid:byte;NAME,DESCR:shortstring);
begin
   with g_uids[uid] do
   begin
      un_txt_name  :=NAME;
      un_txt_udescr:=DESCR;
   end;
end;

procedure hintStrUPID(upid:byte;NAME,DESCR:shortstring);
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


function txt_makeAttributeStr(pu:PTUnit;auid:byte):shortstring;
begin
   if(pu=nil)then
   begin
      pu:=g_punits[0];
      with pu^ do
      begin
         uidi   :=auid;
         playeri:=0;
         player :=@g_players[playeri];
         unit_apllyUID(pu);
         hits   :=hits.MinValue;
      end;
   end;
   txt_makeAttributeStr:='';
   with pu^  do
   with uid^ do
   begin
      if(hits>fdead_hits)then
       if(hits>0)
       then _ADDSTR(@txt_makeAttributeStr,str_attr_alive    ,sep_comma)
       else _ADDSTR(@txt_makeAttributeStr,str_attr_dead     ,sep_comma);

      if(_ukbuilding)
      then _ADDSTR(@txt_makeAttributeStr,str_attr_building  ,sep_comma)
      else _ADDSTR(@txt_makeAttributeStr,str_attr_unit      ,sep_comma);
      if(_ukmech)
      then _ADDSTR(@txt_makeAttributeStr,str_attr_mech      ,sep_comma)
      else _ADDSTR(@txt_makeAttributeStr,str_attr_bio       ,sep_comma);
      if(_uklight)
      then _ADDSTR(@txt_makeAttributeStr,str_attr_light     ,sep_comma)
      else _ADDSTR(@txt_makeAttributeStr,str_attr_heavy     ,sep_comma);
      if(ukfly)
      then _ADDSTR(@txt_makeAttributeStr,str_attr_fly       ,sep_comma)
      else
        if(ukfloater)
        then _ADDSTR(@txt_makeAttributeStr,str_attr_floater,sep_comma)
        else _ADDSTR(@txt_makeAttributeStr,str_attr_ground ,sep_comma);
      if(transportM>0)
      then _ADDSTR(@txt_makeAttributeStr,str_attr_transport,sep_comma);
      if(level>0)
      then _ADDSTR(@txt_makeAttributeStr,str_attr_level+b2s(level+1),sep_comma);
      if(buff[ub_Detect]>0)or(_detector)
      then _ADDSTR(@txt_makeAttributeStr,str_attr_detector,sep_comma);
      if(buff[ub_Invuln]>0)
      then _ADDSTR(@txt_makeAttributeStr,str_attr_invuln,sep_comma)
      else
        if(buff[ub_Pain]>0)
        then _ADDSTR(@txt_makeAttributeStr,str_attr_stuned,sep_comma);

      txt_makeAttributeStr:='['+txt_makeAttributeStr+tc_default+']';
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
   then DamageStr:='x '+str_uhint_TargetLimit
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
  if(length(AddReq)>0)then AddReq:='{'+tc_yellow+str_uhint_req+tc_default+AddReq+'}';
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
       _ADDSTR(@_MakeDefaultDescription,str_uhint_hits+i2s(_mhits),sep_sdot);
       //_ADDSTR(@_MakeDefaultDescription,str_uhint_srange+i2s(_srange),sep_sdot);

       if(_isbuilder    )then _ADDSTR(@_MakeDefaultDescription,str_uhint_builder,sep_sdot);
       if(_isbarrack    )then _ADDSTR(@_MakeDefaultDescription,str_uhint_barrack,sep_sdot);
       if(_issmith      )then _ADDSTR(@_MakeDefaultDescription,str_uhint_smith  ,sep_sdot);
       if(_genergy    >0)then _ADDSTR(@_MakeDefaultDescription,str_uhint_IncEnergyLevel+'('+tc_aqua+'+'+i2s(_genergy)+tc_default+')',sep_sdot);
       {if(_rebuild_uid>0)and(_ability<>ua_RebuildInPoint)then
       begin
          _ADDSTR(@_MakeDefaultDescription,
          str_uhint_CanRebuildTo+
          RebuildStr(_rebuild_uid,_rebuild_level)+
          AddReq(_rebuild_ruid,_rebuild_rupgr,_rebuild_rupgrl),sep_sdot );
       end;
       if(_ability>0)then
       begin
          if(_ability=ua_RebuildInPoint)and(_rebuild_uid>0)
          then _ADDSTR(@_MakeDefaultDescription,str_uhint_ability+str_uhint_transformation+RebuildStr(_rebuild_uid,_rebuild_level)+AddReq(_rebuild_ruid,_rebuild_rupgr,_rebuild_rupgrl),sep_sdot)
          else
            with g_uability[_ability] do
              if(length(ua_name)>0)
              then _ADDSTR(@_MakeDefaultDescription,str_uhint_ability+'"'+ua_name+'"'+AddReq(_ability_ruid,_ability_rupgr,_ability_rupgrl),sep_sdot);
       end
       else
         if(_transportM>0)then _ADDSTR(@_MakeDefaultDescription,str_uhint_ability+'"'+str_ability_unload+'"',sep_sdot); }

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
      wpt_directdmgZ   : if(aw_max_range<0)
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
            if(_a_BonusRangeAntiFly     <>0)then _ADDSTR(@_MakeWeaponString,'bonus anti-fly range: '     +_i2s(_a_BonusRangeAntiFly     ),sep_scomma);
            if(_a_BonusRangeAntiGround  <>0)then _ADDSTR(@_MakeWeaponString,'bonus anti-ground range: '  +_i2s(_a_BonusRangeAntiFly     ),sep_scomma);
            if(_a_BonusRangeAntiUnit    <>0)then _ADDSTR(@_MakeWeaponString,'bonus anti-unit range: '    +_i2s(_a_BonusRangeAntiUnit    ),sep_scomma);
            if(_a_BonusRangeAntiBuilding<>0)then _ADDSTR(@_MakeWeaponString,'bonus anti-building range: '+_i2s(_a_BonusRangeAntiBuilding),sep_scomma);
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
                if(_a_BonusRangeAntiFly   <>0)then _ADDSTR(@_MakeWeaponString,'bonus anti-fly range: '   +_i2s(_a_BonusRangeAntiFly),sep_scomma);
                if(_a_BonusRangeAntiGround<>0)then _ADDSTR(@_MakeWeaponString,'bonus anti-ground range: '+_i2s(_a_BonusRangeAntiFly),sep_scomma);
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
      wpt_directdmg : if(aw_dmod>0)then dmod_str:=DamageStr(aw_dmod);
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
     if(_attack)then
      for w:=0 to MaxUnitWeapons do
       with _a_weap[w] do
        _ADDSTR(@weapons_str,_MakeWeaponString(uid,w,docSTR),sep_sdots);

     if(length(weapons_str)>0)then
      if(docSTR)
      then _ADDSTR(@_MakeWeaponsDescription,weapons_str,sep_sdot)
      else _ADDSTR(@_MakeWeaponsDescription,str_uhint_UnitArming+weapons_str,sep_sdot);
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
     HK  :=hotKeyCommon(_up_btni,@hotkeyP1,@hotkeyP2);
     ENRG:='';
     TIME:='';
     INFO:='';

     if(_up_max<=1)or(_up_mfrg)
     then curlvl:=1
     else
       if(curlvl>_up_max)and(curlvl<255)then curlvl:=_up_max;

     if(_up_renerg>0)then
       if(curlvl<255)
       then ENRG:=tc_aqua +i2s(upid_CalcCostEnergy(upid,curlvl))+tc_default
       else
         if(_up_max>0)then
         begin
            for i:=1 to _up_max do _ADDSTR(@ENRG,i2s(upid_CalcCostEnergy(upid,i)),'/');
            ENRG:=tc_aqua+ENRG+tc_default;
         end;
     if(_up_time  >0)then
       if(curlvl<255)
       then TIME:=tc_white+i2s(upid_CalcCostTime(upid,curlvl)div fr_fps1)+tc_default
       else
         if(_up_max>0)then
         begin
            for i:=1 to _up_max do _ADDSTR(@TIME,i2s(upid_CalcCostTime(upid,i)div fr_fps1),'/');
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
         HK:=hotKeyCommon(_ucl,@hotkeyP1,@hotkeyP2);
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

         un_txt_uihint1:=un_txt_name+' ('+INFO+')'+tc_nl1+txt_makeAttributeStr(nil,uid);
         un_txt_uihintS:=un_txt_name+tc_nl1;
         un_txt_uihint2:=un_txt_fdescr;
         un_txt_uihint3:=_MakeWeaponsDescription(uid,false);
         un_txt_uihint4:='';

         if(length(REQ )>0)then un_txt_uihint4+=tc_yellow+str_uhint_requirements+tc_default+REQ+tc_nl1
                           else un_txt_uihint4+=tc_nl1;
         if(length(PROD)>0)then
          if(_ukbuilding)
          then un_txt_uihint4+=str_uhint_bprod+PROD
          else un_txt_uihint4+=str_uhint_uprod+PROD;
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
      if(length(REQ)>0)then _up_hint+=tc_yellow+str_uhint_requirements+tc_default+REQ;
   end;
end;

procedure language_ENG;
var t: shortstring;
    p: byte;
begin
   str_bool[false]                   := tc_red +'no';
   str_bool[true ]                   := tc_lime+'yes';

   str_error_FileExists              := 'File not exists!';
   str_error_OpenFile                := 'Can`t open file!';
   str_error_WrongData               := 'Wrong file size!';
   str_error_FileRead                := 'Read file error!';
   str_error_FileWrite               := 'Write file error!';
   str_error_WrongVersion            := 'Wrong version!';
   str_error_ServerFull              := 'Server full!';
   str_error_GameStarted             := 'Game started!';

   str_ptype_AI                      := 'AI';
   str_ptype_cheater                 := 'cheater';

   str_menu_StartGame                := 'START GAME';
   str_menu_EndGame                  := 'END GAME';
   str_menu_Campaings                := 'CAMPAIGNS';
   str_menu_Scirmish                 := 'SCIRMISH';
   str_menu_SaveLoad                 := 'SAVE/LOAD';
   str_menu_LoadGame                 := 'LOAD GAME';
   str_menu_LoadReplay               := 'LOAD REPLAY';
   str_menu_Settings                 := 'SETTINGS';
   str_menu_AboutGame                := 'ABOUT GAME';
   str_menu_ReplayPlayback           := 'REPLAY PLAYBACK';
   str_menu_ReplayQuit               := 'QUIT REPLAY';

   str_menu_Surrender                := 'SURRENDER';
   str_menu_LeaveGame                := 'LEAVE GAME';
   str_menu_Back                     := 'BACK';
   str_menu_Exit                     := 'EXIT';
   str_menu_Start                    := 'START';
   str_menu_lang[true ]              := 'RUS';
   str_menu_lang[false]              := 'ENG';
   str_menu_maction                  := 'Mouse right-click action';
   str_menu_mactionl[true ]          := tc_lime+'move'+tc_default;
   str_menu_mactionl[false]          := tc_lime+'move'+tc_default+'+'+tc_red+'attack'+tc_default;
   str_menu_connecting               := 'Connecting...';
   str_menu_settingsGame             := 'GAME';
   str_menu_settingsReplay           := 'REPLAY';
   str_menu_settingsNetwork          := 'NETWORK';
   str_menu_settingsVideo            := 'VIDEO';
   str_menu_settingsSound            := 'SOUND';
   str_menu_DeleteFile               := 'DELETE';

   str_menu_save                     := 'SAVE';
   str_menu_load                     := 'LOAD';


   str_menu_Apply                    := 'APPLY';
   str_menu_ResolutionWidth          := 'Resolution (width)';
   str_menu_ResolutionHeight         := 'Resolution (height)';
   str_menu_fullscreen               := 'Windowed';
   str_menu_FPS                      := 'Show FPS';

   str_menu_MusicVolume              := 'Music volume';
   str_menu_SoundVolume              := 'Sound volume';
   str_menu_NextTrack                := 'Play next track';
   str_menu_MusicReload              := 'Reload music playlist';
   str_menu_PlayListSize             := 'Music playlist size';

   str_menu_APM                      := 'Show APM';
   str_menu_language                 := 'UI language';
   str_menu_ColoredShadow            := 'Colored shadows';
   str_menu_ScrollSpeed              := 'Scroll speed';
   str_menu_MouseScroll              := 'Mouse scroll';
   str_menu_PlayerName               := 'Player name';

   str_menu_client                   := 'CLIENT';
   str_menu_clientAddress            := 'Address';
   str_menu_clientConnect            := 'Connect';
   str_menu_clientDisconnect         := 'Disconnect';
   str_menu_clientQuality            := 'Net traffic/Units upd. rate';
   str_menu_LANSearching             := 'Searching for LAN servers...';
   str_menu_LANSearchStop            := 'Stop searching';
   str_menu_LANSearchStart           := 'Search for LAN servers';
   str_menu_server                   := 'SERVER';
   str_menu_serverPort               := 'Server port(UDP)';
   str_menu_ready                    := 'ready';
   str_menu_nready                   := 'not ready';
   str_menu_serverStart              := 'Start server';
   str_menu_serverStop               := 'Stop server';
   str_menu_chat                     := 'CHAT';

   str_menu_ReplayName               := 'Replay name';
   str_menu_ReplayQuality            := 'Replay quality/File size';
   str_menu_Recording                := 'Record games';
   str_menu_ReplayState              := 'Replay status';
   str_menu_ReplayStatel[rpls_state_none ]:=           'OFF';
   str_menu_ReplayStatel[rpls_state_write]:= tc_yellow+'RECORD';
   str_menu_ReplayStatel[rpls_state_read ]:= tc_lime  +'PLAY';
   str_menu_ReplayPlay               := 'PLAY';

   str_menu_NetQuality[0]            := tc_aqua  +'x1 '+tc_default+'/'+tc_red   +'x1';
   str_menu_NetQuality[1]            := tc_aqua  +'x2 '+tc_default+'/'+tc_red   +'x2';
   str_menu_NetQuality[2]            := tc_lime  +'x3 '+tc_default+'/'+tc_orange+'x3';
   str_menu_NetQuality[3]            := tc_lime  +'x4 '+tc_default+'/'+tc_orange+'x4';
   str_menu_NetQuality[4]            := tc_yellow+'x5 '+tc_default+'/'+tc_yellow+'x5';
   str_menu_NetQuality[5]            := tc_yellow+'x6 '+tc_default+'/'+tc_yellow+'x6';
   str_menu_NetQuality[6]            := tc_orange+'x7 '+tc_default+'/'+tc_lime  +'x7';
   str_menu_NetQuality[7]            := tc_orange+'x8 '+tc_default+'/'+tc_lime  +'x8';
   str_menu_NetQuality[8]            := tc_red   +'x9 '+tc_default+'/'+tc_aqua  +'x9';
   str_menu_NetQuality[9]            := tc_red   +'x10'+tc_default+'/'+tc_aqua  +'x10';

   str_menu_Name                     := 'NAME';
   str_menu_Slot                     := 'SLOT STATE';
   str_menu_Race                     := 'RACE';
   str_menu_Team                     := 'TEAM';
   str_menu_Color                    := 'COLOR';

   str_menu_players                  := 'PLAYERS';
   str_menu_map                      := 'MAP';
   str_menu_GameOptions              := 'GAME OPTIONS';
   str_menu_multiplayer              := 'MULTIPLAYER';
   str_menu_ReplayInfo               := 'REPLAY INFO';
   str_menu_SaveInfo                 := 'SAVE INFO';

   str_menu_PanelPos                 := 'Control panel position';
   str_menu_PanelPosl[0]             := tc_lime  +'left'  +tc_default;
   str_menu_PanelPosl[1]             := tc_orange+'right' +tc_default;
   str_menu_PanelPosl[2]             := tc_yellow+'top'   +tc_default;
   str_menu_PanelPosl[3]             := tc_aqua  +'bottom'+tc_default;

   // [vertical][]
   str_menu_MiniMapPos               := 'Mini map position';
   str_menu_MiniMapPosl[true ][true ]:= str_menu_PanelPosl[2];
   str_menu_MiniMapPosl[true ][false]:= str_menu_PanelPosl[3];
   str_menu_MiniMapPosl[false][true ]:= str_menu_PanelPosl[0];
   str_menu_MiniMapPosl[false][false]:= str_menu_PanelPosl[1];

   str_menu_unitHBar                 := 'Health bars';
   str_menu_unitHBarl[0]             := tc_lime  +'selected'+tc_default+'+'+tc_red+'damaged'+tc_default;
   str_menu_unitHBarl[1]             := tc_aqua  +'always'  +tc_default;
   str_menu_unitHBarl[2]             := tc_orange+'only '   +tc_lime+'selected'+tc_default;

   str_menu_PlayersColor             := 'Players color';
   str_menu_PlayersColorl[0]         := tc_white +'default'+tc_default;
   str_menu_PlayersColorl[1]         := tc_lime  +'own '   +tc_yellow+'ally '+tc_red+'enemy'+tc_default;
   str_menu_PlayersColorl[2]         := tc_white +'own '   +tc_yellow+'ally '+tc_red+'enemy'+tc_default;
   str_menu_PlayersColorl[3]         := tc_white +'own '   +tc_aqua  +'ally '+tc_red+'enemy'+tc_default;
   str_menu_PlayersColorl[4]         := tc_lime+'t'+tc_red+'e'+tc_aqua+'a'+tc_yellow+'m'+tc_blue+'s'  +tc_default;
   str_menu_PlayersColorl[5]         := tc_white +'own '   +str_menu_PlayersColorl[4];

   str_menu_PlayerSlots[pss_closed  ] :='closed';
   str_menu_PlayerSlots[pss_observer] :='observer';
   str_menu_PlayerSlots[pss_opened  ] :='opened';
   str_menu_PlayerSlots[pss_ready   ] :='ready';
   str_menu_PlayerSlots[pss_nready  ] :='not ready';
   str_menu_PlayerSlots[pss_swap    ] :='jump here';
   str_menu_PlayerSlots[pss_sobserver]:='become observer';
   str_menu_PlayerSlots[pss_splayer ] :='become player';

   for p:=pss_AI_1 to pss_AI_11 do
   str_menu_PlayerSlots[p]           :=ai_name(p-pss_AI_1+1);

   str_menu_RandomScirmish           := 'Make Random Skirmish';
   str_menu_AISlots                  := 'Fill empty slots';
   str_menu_DeadObservers            := 'Observer mode after lose';
   str_menu_FixedStarts              := 'Fixed player starts';

   str_menu_GameMode                 := 'Game mode';
   str_emnu_GameModel[gm_scirmish]   := tc_lime  +'Skirmish'        +tc_default;
   str_emnu_GameModel[gm_4x4     ]   := tc_orange+'4x4'             +tc_default;
   str_emnu_GameModel[gm_2x2x2x2 ]   := tc_yellow+'2x2x2x2'         +tc_default;
   str_emnu_GameModel[gm_capture ]   := tc_aqua  +'Capturing points'+tc_default;
   str_emnu_GameModel[gm_KotH    ]   := tc_purple+'King of the Hill'+tc_default;
   str_emnu_GameModel[gm_royale  ]   := tc_red   +'Battle Royale'   +tc_default;
   str_emnu_GameModel[gm_assault ]   := tc_blue  +'Assault'         +tc_default;

   str_menu_Generators               := 'Generators';
   str_menu_Generatorsl[0]           := 'own';
   str_menu_Generatorsl[1]           := 'neutral(5 min)';
   str_menu_Generatorsl[2]           := 'neutral(10 min)';
   str_menu_Generatorsl[3]           := 'neutral(15 min)';
   str_menu_Generatorsl[4]           := 'neutral(20 min)';
   str_menu_Generatorsl[5]           := 'neutral(infinity)';

   str_map_type                      := 'Type';
   str_map_typel[mapt_steppe]        := tc_gray  +'Steppe';
   str_map_typel[mapt_canyon]        := tc_blue  +'Canyon';
   str_map_typel[mapt_clake ]        := tc_aqua  +'Lake';
   str_map_typel[mapt_ilake ]        := tc_green +'Lake&islands';
   str_map_typel[mapt_island]        := tc_yellow+'Island';
   str_map_typel[mapt_shore ]        := tc_orange+'Sea shore';
   str_map_typel[mapt_sea   ]        := tc_red   +'Sea';
   str_map_seed                      := 'Seed';
   str_map_size                      := 'Size';
   str_map_sym                       := 'Symmetry';
   str_map_syml[maps_none ]          := 'no';
   str_map_syml[maps_point]          := 'point';
   str_map_syml[maps_lineV]          := 'line |';
   str_map_syml[maps_lineh]          := 'line -';
   str_map_syml[maps_lineL]          := 'line \';
   str_map_syml[maps_lineR]          := 'line /';
   str_map_random                    := 'Random map';

   str_racel[r_random]               := tc_default+'RANDOM';
   str_racel[r_hell  ]               := tc_orange+'HELL'+tc_default;
   str_racel[r_uac   ]               := tc_lime  +'UAC' +tc_default;
   str_observer                      := 'OBSERVER';

   str_msg_ReplayStart               := 'Start recording: ';
   str_msg_ReplayFail                := 'Recording error! ';
   str_msg_PlayerDefeated            := ' was terminated';
   str_msg_PlayerLeave               := ' left the game';
   str_msg_PlayerSurrender           := ' gives up';
   str_msg_GameSaved                 := 'Game saved';
   str_msg_PlayerPaused              := 'player paused the game';
   str_msg_PlayerResumed             := 'player has resumed the game';

   str_win                           := 'VICTORY!';
   str_lose                          := 'DEFEAT!';
   str_gsunknown                     := 'Unknown status!';
   str_pause                         := 'Pause';
   str_repend                        := 'Replay ended!';
   str_waitsv                        := 'Awaiting server...';

   str_demons                        := 'demons&zombies';
   str_except                        := 'except';
   str_splashresist                  := 'Immune to splash damage';

   str_chat_all                      := 'ALL:';
   str_chat_allies                   := 'ALLIES:';

   str_uhint_TargetLimit             := 'target limit';
   str_uhint_req                     := 'Req.: ';
   str_uhint_builder                 := 'Builder';
   str_uhint_barrack                 := 'Unit production';
   str_uhint_smith                   := 'Researches and upgrades facility';
   str_uhint_IncEnergyLevel          := 'Increases energy level';
   str_uhint_CanRebuildTo            := 'Can be rebuilt into ';
   str_uhint_UnitArming              := 'Arming/Abilities: ';
   str_uhint_hits                    := 'Hits: ';
   str_uhint_srange                  := 'Base sight range: ';
   str_uhint_UnitLevel               := 'Upgrades: ';
   str_uhint_ability                 := 'Special ability: ';
   str_uhint_transformation          := 'transformation into ';
   str_uhint_requirements            := 'Requirements: ';
   str_uhint_uprod                   := tc_lime+'Produced by: '   +tc_default;
   str_uhint_bprod                   := tc_lime+'Constructed by: '+tc_default;

   str_weapon_melee                  := 'melee attack';
   str_weapon_ranged                 := 'ranged attack';
   str_weapon_zombie                 := '+zombification';
   str_weapon_ressurect              := 'resurrection';
   str_weapon_heal                   := 'heal/repair';
   str_weapon_spawn                  := 'spawn';
   str_weapon_suicide                := 'suicide';
   str_weapon_targets                := 'targets: ';
   str_weapon_damage                 := 'impact';

   str_uiWarn_CantBuild              := 'Can`t build here';
   str_uiWarn_NeedEnergy             := 'Need more energy';
   str_uiWarn_CantProd               := 'Can`t production it';
   str_uiWarn_CheckReqs              := 'Check requirements';
   str_uiWarn_CantExecute            := 'Impossible order';
   str_uiWarn_UnitPromoted           := 'Unit promoted';
   str_uiWarn_UpgradeComplete        := 'Upgrade complete';
   str_uiWarn_BuildingComplete       := 'Construction complete';
   str_uiWarn_UnitComplete           := 'Unit ready';
   str_uiWarn_UnitAttacked           := 'Unit is under attack';
   str_uiWarn_BaseAttacked           := 'Base is under attack';
   str_uiWarn_AlliesAttacked         := 'Our allies is under attack';
   str_uiWarn_MaxLimitReached        := 'Maximum army limit reached';
   str_uiWarn_NeedMoreBuilders       := 'Need more builders';
   str_uiWarn_ProductionBusy         := 'All production buildings are busy';
   str_uiWarn_CantRebuild            := 'Impassible to rebuild';
   str_uiWarn_NeedMoreProd           := 'Nowhere to produce it';
   str_uiWarn_MaximumReached         := 'Maximum reached';
   str_uiWarn_MapMark                := ' set a mark on the map';

   str_attr_alive                    := tc_lime  +'alive'       ;
   str_attr_dead                     := tc_dgray +'dead'        ;
   str_attr_unit                     := tc_gray  +'unit'        ;
   str_attr_building                 := tc_red   +'building'    ;
   str_attr_mech                     := tc_blue  +'mechanical'  ;
   str_attr_bio                      := tc_orange+'biological'  ;
   str_attr_light                    := tc_yellow+'light'       ;
   str_attr_heavy                    := tc_green +'heavy'       ;
   str_attr_fly                      := tc_white +'flying'      ;
   str_attr_ground                   := tc_lime  +'ground'      ;
   str_attr_floater                  := tc_aqua  +'floater'     ;
   str_attr_level                    := tc_white +'level'       ;
   str_attr_invuln                   := tc_lime  +'invulnerable';
   str_attr_stuned                   := tc_yellow+'stuned'      ;
   str_attr_detector                 := tc_purple+'detector'    ;
   str_attr_transport                := tc_gray  +'transport'   ;

   //str_teams[0]                      := str_observer;
   for p:=0 to LastPlayer do
   str_teams[p]                      := 'team '+b2s(p+1);

   {
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


  }

   {
   str_udpport           := 'UDP port';
   str_svup[false]       := 'Start server';
   str_svup[true ]       := 'Stop server';
   str_connect[false]    := 'Connect';
   str_connect[true ]    := 'Disconnect';
   str_replay_Quality    := 'File size/quality';

   str_netsearching      := 'Searching for servers...';


   }

   {
   }

      {str_MMap              := 'MAP';
      str_MPlayers          := 'PLAYERS';
      str_MObjectives       := 'OBJECTIVES';
      str_MServers          := 'SERVERS';}
   {
   str_players           := 'Players';

   str_save              := 'Save';
   str_load              := 'Load';
   str_delete            := 'Delete';
   str_play              := 'Play';
   str_replay            := 'RECORD';
   str_replay_status     := 'STATUS';
   str_menu_ReplayName       := 'Replay name';
   str_cmpdif            := 'Difficulty ';
   str_goptions          := 'GAME OPTIONS';

   str_client            := 'CLIENT';
   str_menu_chat         := 'CHAT(ALL PLAYERS)';
   str_Address           := 'Address'; }

   str_uiHint_Army                   := 'Army: ';
   str_uiHint_Energy                 := 'Energy: ';
   str_uiHint_UGroups                := 'Unit groups: ';
   str_uiHint_Time                   := 'Time: ';
   str_uiHint_KotHTime               := 'Center capture time left: ';
   str_uiHint_KotHTimeAct            := 'Time left until center area is active: ';
   str_uiHint_KotHWinner             := ' is King of the Hill!';

   str_panelHint_Common[0]           := 'Menu (' +tc_lime+'Esc'+tc_default+')';
   str_panelHint_Common[1]           := '';
   str_panelHint_Common[2]           := 'Pause ('+tc_lime+'Pause/Break'+tc_default+')';
   str_panelHint_Tab[0]              := 'Buildings';
   str_panelHint_Tab[1]              := 'Units';
   str_panelHint_Tab[2]              := 'Researches';
   str_panelHint_Tab[3]              := 'Controls';
   str_panelHint_all                 := 'All';
   str_panelHint_menu                := 'Menu';

   g_presets[gp_custom   ].gp_name   := 'custom preset';
   MakeGamePresetsNames(@str_emnu_GameModel[0],@str_map_typel[0]);

   theme_name[0] := tc_lime  +'UAC BASE';
   theme_name[1] := tc_blue  +'TECH BASE';
   theme_name[2] := tc_dgray +'UNKNOWN PLANET';
   theme_name[3] := tc_white +'UNKNOWN MOON';
   theme_name[4] := tc_gray  +'CAVES';
   theme_name[5] := tc_aqua  +'ICE CAVES';
   theme_name[6] := tc_orange+'HELL';
   theme_name[7] := tc_yellow+'HELL CAVES';
   theme_name[8] := tc_red   +'HELL CITY';

   t:='attack enemies';
   SetStrUAbility(ua_amove        ,'Move, '  +t           ,'');
   SetStrUAbility(ua_apatrol      ,'Patrol, '+t           ,'');
   SetStrUAbility(ua_astay        ,'Stay, '  +t           ,'');
   t:='ignore enemies';
   SetStrUAbility(ua_move         ,'Move, '  +t           ,'');
   SetStrUAbility(ua_patrol       ,'Patrol, '+t           ,'');
   SetStrUAbility(ua_stay         ,'Stay, '  +t           ,'');

   SetStrUAbility(ua_destroy      ,'Destroy'              ,'');
   SetStrUAbility(ua_unload       ,'Unload'               ,'');
   SetStrUAbility(ua_unloadto     ,'Unload at point'      ,'');
   SetStrUAbility(ua_Upgrade      ,'Upgrade'              ,'');


   hintStrUID(UID_HKeep            ,'Hell Keep'                   ,'');
   hintStrUID(UID_HGate            ,'Demon`s Gate'                ,'');
   hintStrUID(UID_HSymbol          ,'Unholy Symbol'               ,'');
   hintStrUID(UID_HPools           ,'Infernal Pools'              ,'');
   hintStrUID(UID_HTeleport        ,'Teleporter'                  ,'');
   hintStrUID(UID_HPentagram       ,'Pentagram of Death'          ,'');
   hintStrUID(UID_HMonastery       ,'Monastery of Despair'        ,'');
   hintStrUID(UID_HFortress        ,'Castle of the Damned'        ,'');
   hintStrUID(UID_HTower           ,'Guard Tower'                 ,'Defensive structure'              );
   hintStrUID(UID_HTotem           ,'Totem of Horror'             ,'Advanced defensive structure'     );
   hintStrUID(UID_HAltar           ,'Altar of Pain'               ,'');
   hintStrUID(UID_HCommandCenter   ,'Hell Command Center'         ,'Corrupted Command Center'         );
   hintStrUID(UID_HBarracks        ,'Zombie Barracks'             ,'Corrupted Barracks'               );
   hintStrUID(UID_HEye             ,'Evil Eye'                    ,'Passive scouting and detection'   );

   hintStrUID(UID_LostSoul         ,'Lost Soul'                   ,'');
   hintStrUID(UID_Phantom          ,'Phantom'                     ,'');
   hintStrUID(UID_Imp              ,'Imp'                         ,'');
   hintStrUID(UID_Demon            ,'Pinky Demon'                 ,'');
   hintStrUID(UID_Cacodemon        ,'Cacodemon'                   ,'');
   hintStrUID(UID_Knight           ,'Hell Knight'                 ,'');
   hintStrUID(UID_Baron            ,'Baron of Hell'               ,'');
   hintStrUID(UID_Cyberdemon       ,'Cyberdemon'                  ,'');
   hintStrUID(UID_Mastermind       ,'Spider Mastermind'           ,'');
   hintStrUID(UID_Pain             ,'Pain Elemental'              ,'');
   hintStrUID(UID_Revenant         ,'Revenant'                    ,'');
   hintStrUID(UID_Mancubus         ,'Mancubus'                    ,'');
   hintStrUID(UID_Arachnotron      ,'Arachnotron'                 ,'');
   hintStrUID(UID_Archvile         ,'Arch-Vile'                   ,'');
   hintStrUID(UID_ZMedic          ,'Former Zombie'               ,'');
   hintStrUID(UID_ZEngineer        ,'Zombie Engineer'             ,'');
   hintStrUID(UID_ZSergant         ,'Zombie Shotgunner'           ,'');
   hintStrUID(UID_ZSSergant        ,'Zombie SuperShotgunner'      ,'');
   hintStrUID(UID_ZCommando        ,'Zombie Commando'             ,'');
   hintStrUID(UID_ZAntiaircrafter  ,'Anti-aircraft Zombie'        ,'');
   hintStrUID(UID_ZSiegeMarine     ,'Zombie Siege Marine'         ,'');
   hintStrUID(UID_ZFPlasmagunner   ,'Zombie Plasmagunner'         ,'');
   hintStrUID(UID_ZBFGMarine       ,'Zombie BFG Marine'           ,'');

   //g_uability
   {
          = 16;
             = 17;
           = 18;
           = 19;
            = 20;
              = 21;
                = 22;
             = 23;
           = 24;
          = 25;
           = 26;

   ua_HSpawnLost          = 27;
   ua_HSpawnLostTo        = 28;

   ua_UCCUp               = 30;
   ua_UCCLand             = 31;
   ua_UTurretG2A          = 32;
   ua_UTurretA2G          = 33;
   ua_UTurret2Drone       = 34;
   ua_UScan               = 35;
   ua_UStrike             = 36;
   ua_USphereSoul         = 37;
   ua_USphereInvis        = 38;
   ua_USphereInvuln       = 39;
   }


   SetStrUAbility(ua_HKeepPainAura,'Decay Aura'           ,'');
   SetStrUAbility(ua_HKeepBlink   ,'Hell Keep Blink'      ,'');
   SetStrUAbility(ua_HR2Totem     ,'Rebuild to '+g_uids[UID_HTotem].un_txt_name,'');
   SetStrUAbility(ua_HR2Tower     ,'Rebuild to '+g_uids[UID_HTower].un_txt_name,'');
   SetStrUAbility(ua_HShortBlink  ,'Tower Teleportation'  ,'');
   SetStrUAbility(ua_HTeleport    ,'Teleport'             ,'');
   SetStrUAbility(ua_HRecall      ,'Recall'               ,'');
   SetStrUAbility(ua_HellVision   ,'Hell Vision'          ,'');
   SetStrUAbility(ua_HSphereArmor ,'Armor Shpere'         ,'');
   SetStrUAbility(ua_HSphereDamage,'Double Damage Sphere' ,'');
   SetStrUAbility(ua_HSphereHaste ,'Haste Sphere'         ,'');


   hintStrUPID(upgr_hell_t1attack  ,'Hell Firepower'                ,'Increase the damage of ranged attacks for T1 units and defensive structures');
   hintStrUPID(upgr_hell_uarmor    ,'Combat Flesh'                  ,'Increase the armor of all Hell units'                                   );
   hintStrUPID(upgr_hell_barmor    ,'Stone Walls'                   ,'Increase the armor of all Hell buildings'                               );
   hintStrUPID(upgr_hell_mattack   ,'Claws and Teeth'               ,'Increase the damage of melee attacks'                                   );
   hintStrUPID(upgr_hell_regen     ,'Flesh Regeneration'            ,'Health regeneration for all Hell units'                                 );
   hintStrUPID(upgr_hell_pains     ,'Pain Threshold'                ,'Hell units can take more hits before being stunned by pain'             );
   hintStrUPID(upgr_hell_towers    ,'Demonic Spirits'               ,'Increase the range of defensive structures'                             );
   hintStrUPID(upgr_hell_HKTeleport,'Hell Keep Blink Charge'        ,'Charge for the Hell Keep`s ability'                                     );
   hintStrUPID(upgr_hell_paina     ,'Decay Aura'                    ,'Hell Keep damages all nearby enemy units. Decay Aura damage ignores unit armor.');
   hintStrUPID(upgr_hell_buildr    ,'Hell Keep Range Upgrade'       ,'Increase the Hell Keep`s range of vision'                               );

   hintStrUPID(upgr_hell_spectre   ,'Specters'                      ,'Pinky Demons become invisible'                                  );
   hintStrUPID(upgr_hell_vision    ,'Hell Sight'                    ,'Increase the sight range of all Hell units'                     );
   hintStrUPID(upgr_hell_phantoms  ,'Phantoms'                      ,'Pain Elemental spawns Phantoms instead of Lost Souls'            );
   hintStrUPID(upgr_hell_t2attack  ,'Demonic Weapons'               ,'Increase the damage of ranged attacks for T2 units and defensive structures'  );
   hintStrUPID(upgr_hell_teleport  ,'Teleporter Upgrade'            ,'Reduced cooldown on Teleporter ability'                         );
   hintStrUPID(upgr_hell_rteleport ,'Reverse Teleportation'         ,'Units can teleport back to Teleporter'                          );
   hintStrUPID(upgr_hell_heye      ,'Evil Eye Upgrade'              ,'Increase the sight range of Evil Eye'                           );
   hintStrUPID(upgr_hell_totminv   ,'Totem of Horror Invisibility'  ,'Totem of Horror becomes invisible'                              );
   hintStrUPID(upgr_hell_bldrep    ,'Building Restoration'          ,'Health regeneration for all Hell buildings'                     );
   hintStrUPID(upgr_hell_tblink    ,'Tower Teleportation Charge'    ,'Charges for the ability of Guard Tower and Totem of Horror');
   hintStrUPID(upgr_hell_resurrect ,'Resurrection'                  ,'ArchVile`s ability'                    );
   hintStrUPID(upgr_hell_invuln    ,'Invulnerability Sphere'        ,'Charge for the Altar of Pain ability'      );


   hintStrUID(UID_UCommandCenter   ,'Command Center'                ,''      );
   hintStrUID(UID_UBarracks        ,'Barracks'                      ,''      );
   hintStrUID(UID_UFactory         ,'Vehicle Factory'               ,''      );
   hintStrUID(UID_UGenerator       ,'Generator'                     ,''      );
   hintStrUID(UID_UWeaponFactory   ,'Weapons Factory'               ,''      );
   hintStrUID(UID_UGTurret         ,'Anti-ground Turret'            ,'Anti-ground defensive structure');
   hintStrUID(UID_UATurret         ,'Anti-air Turret'               ,'Anti-air defensive structure'   );
   hintStrUID(UID_UTechCenter      ,'Science Facility'              ,'');
   hintStrUID(UID_UComputerStation ,'Computer Station'              ,'');
   hintStrUID(UID_URadar           ,'Radar'                         ,'Reveals map');
   hintStrUID(UID_URMStation       ,'Rocket Launcher Station'       ,'');

   hintStrUID(UID_Sergant          ,'Shotguner'                     ,'');
   hintStrUID(UID_SSergant         ,'SuperShotguner'                ,'');
   hintStrUID(UID_Commando         ,'Commando'                      ,'');
   hintStrUID(UID_Antiaircrafter   ,'Anti-aircraft Marine'          ,'');
   hintStrUID(UID_SiegeMarine      ,'Siege Marine'                  ,'');
   hintStrUID(UID_FPlasmagunner    ,'Plasmagunner'                  ,'');
   hintStrUID(UID_BFGMarine        ,'BFG Marine'                    ,'');
   hintStrUID(UID_Engineer         ,'Engineer'                      ,'');
   hintStrUID(UID_Medic            ,'Medic'                         ,'');
   hintStrUID(UID_UTransport       ,'Dropship'                      ,'');
   hintStrUID(UID_UACDron          ,'Drone'                         ,'');
   hintStrUID(UID_Terminator       ,'Terminator'                    ,'');
   hintStrUID(UID_Tank             ,'Tank'                          ,'');
   hintStrUID(UID_Flyer            ,'Fighter'                       ,'');


   hintStrUPID(upgr_uac_attack     ,'Weapons Upgrade'                  ,'Increase the damage of ranged attacks for all UAC units and defensive structures');
   hintStrUPID(upgr_uac_uarmor     ,'Infantry Combat Armor Upgrade'    ,'Increase the armor of all Barracks-produced units'             );
   hintStrUPID(upgr_uac_barmor     ,'Concrete Walls'                   ,'Increase the armor of all UAC buildings'                       );
   hintStrUPID(upgr_uac_melee      ,'Advanced Tools'                   ,'Increase repair/healing efficiency of Engineers/Medics'        );
   hintStrUPID(upgr_uac_mspeed     ,'Lightweight Armor'                ,'Increase the movement speed of all Barracks-produced units'            );
   hintStrUPID(upgr_uac_ssgup      ,'Expansive bullets'                ,'Shotgunner, SuperShotgunner and Terminator deal more damage to ['+str_attr_bio+']' );
   hintStrUPID(upgr_uac_towers     ,'Spotlights'                       ,'Increase the range of defensive structures'                    );
   hintStrUPID(upgr_uac_CCFly      ,'Command Center Flight Engines'    ,'Command Center gains ability to fly'                           );
   hintStrUPID(upgr_uac_ccturr     ,'Command Center Turret'            ,'Plasma turret for Command Center'                              );
   hintStrUPID(upgr_uac_buildr     ,'Command Center Range Upgrade'     ,'Increase Command Center`s range of vision'                           );

   hintStrUPID(upgr_uac_botturret  ,'Drone Transformation Protocol'    ,'A Drone can rebuild to Anti-ground turret'    );
   hintStrUPID(upgr_uac_vision     ,'Light Amplification Visors'       ,'Increase the sight range of all UAC units'  );
   hintStrUPID(upgr_uac_commando   ,'Stealth Technology'               ,'Commando becomes invisible'                 );
   hintStrUPID(upgr_uac_airsp      ,'Fragmentation Missiles'           ,'Anti-air missiles do extra damage around the target'  );
   hintStrUPID(upgr_uac_mechspd    ,'Advanced Engines'                 ,'Increase the movement speed of all Factory-produced units'      );
   hintStrUPID(upgr_uac_mecharm    ,'Mech Combat Armor Upgrade'        ,'Increase the armor of all Factory-produced units'               );
   hintStrUPID(upgr_uac_lturret    ,'Fighter Laser Gun'                ,'Fighter anti-ground weapon'                              );
   hintStrUPID(upgr_uac_transport  ,'Dropship Upgrade'                 ,'Increase the capacity of the Dropship'                   );
   hintStrUPID(upgr_uac_radar_r    ,'Radar Upgrade'                    ,'Increase radar scanning radius'             );
   hintStrUPID(upgr_uac_plasmt     ,'Anti-ground Plasmagun'            ,'Anti-['+str_attr_mech+'] weapon for Anti-ground turret'           );
   hintStrUPID(upgr_uac_turarm     ,'Additional Armoring'              ,'Additional armor for Turrets'               );
   hintStrUPID(upgr_uac_rstrike    ,'Rocket Strike Charge'             ,'Charge for Rocket Launcher Station ability' );


   SetHintStr(3 ,@str_panelHint_a,@hotkeyA1,@hotkeyA2,false,g_uability[ua_amove  ].ua_name);
   SetHintStr(4 ,@str_panelHint_a,@hotkeyA1,@hotkeyA2,false,g_uability[ua_astay  ].ua_name);
   SetHintStr(5 ,@str_panelHint_a,@hotkeyA1,@hotkeyA2,false,g_uability[ua_apatrol].ua_name);
   SetHintStr(6 ,@str_panelHint_a,@hotkeyA1,@hotkeyA2,false,g_uability[ua_move   ].ua_name);
   SetHintStr(7 ,@str_panelHint_a,@hotkeyA1,@hotkeyA2,false,g_uability[ua_stay   ].ua_name);
   SetHintStr(8 ,@str_panelHint_a,@hotkeyA1,@hotkeyA2,false,g_uability[ua_patrol ].ua_name);
   SetHintStr(9 ,@str_panelHint_a,@hotkeyA1,@hotkeyA2,false,'Cancel production');
   SetHintStr(10,@str_panelHint_a,@hotkeyA1,@hotkeyA2,false,'To nearest base' );
   SetHintStr(11,@str_panelHint_a,@hotkeyA1,@hotkeyA2,false,'Select all battle units' );
   SetHintStr(12,@str_panelHint_a,@hotkeyA1,@hotkeyA2,false,'Destroy'          );
   SetHintStr(13,@str_panelHint_a,@hotkeyA1,@hotkeyA2,false,'Alarm mark'       );
   SetHintStr(14,@str_panelHint_a,@hotkeyA1,@hotkeyA2,false,str_menu_maction);

   SetHintStr(0 ,@str_panelHint_r,@hotkeyR1,@hotkeyR2,false,'Faster game speed'    );
   SetHintStr(1 ,@str_panelHint_r,@hotkeyR1,@hotkeyR2,true ,'Left click: back 2 seconds ('                                +tc_lime+'W'+tc_default+')'+tc_nl1+
                                                            'Right click: back 10 seconds ('+tc_lime+'Ctrl'+tc_default+'+'+tc_lime+'W'+tc_default+')'+tc_nl1+
                                                            'Middle click: back 1 minute (' +tc_lime+'Alt' +tc_default+'+'+tc_lime+'W'+tc_default+')'        );
   SetHintStr(2 ,@str_panelHint_r,@hotkeyR1,@hotkeyR2,true ,'Left click: skip 2 seconds ('                                +tc_lime+'E'+tc_default+')'+tc_nl1+
                                                            'Right click: skip 10 seconds ('+tc_lime+'Ctrl'+tc_default+'+'+tc_lime+'E'+tc_default+')'+tc_nl1+
                                                            'Middle click: skip 1 minute (' +tc_lime+'Alt' +tc_default+'+'+tc_lime+'E'+tc_default+')'        );
   SetHintStr(3 ,@str_panelHint_r,@hotkeyR1,@hotkeyR2,false,'Pause'                );
   SetHintStr(4 ,@str_panelHint_r,@hotkeyR1,@hotkeyR2,false,'Player-recorder POV'  );
   SetHintStr(5 ,@str_panelHint_r,@hotkeyR1,@hotkeyR2,false,'List of game messages');
   SetHintStr(6 ,@str_panelHint_r,@hotkeyR1,@hotkeyR2,false,'Fog of war'           );
   SetHintStr(8 ,@str_panelHint_r,@hotkeyR1,@hotkeyR2,false,'Vision: All players'  );
   SetHintStr(9 ,@str_panelHint_r,@hotkeyR1,@hotkeyR2,false,'Vision: Player #1'    );
   SetHintStr(10,@str_panelHint_r,@hotkeyR1,@hotkeyR2,false,'Vision: Player #2'    );
   SetHintStr(11,@str_panelHint_r,@hotkeyR1,@hotkeyR2,false,'Vision: Player #3'    );
   SetHintStr(12,@str_panelHint_r,@hotkeyR1,@hotkeyR2,false,'Vision: Player #4'    );
   SetHintStr(13,@str_panelHint_r,@hotkeyR1,@hotkeyR2,false,'Vision: Player #5'    );
   SetHintStr(14,@str_panelHint_r,@hotkeyR1,@hotkeyR2,false,'Vision: Player #6'    );
   SetHintStr(15,@str_panelHint_r,@hotkeyR1,@hotkeyR2,false,'Vision: Player #7'    );
   SetHintStr(16,@str_panelHint_r,@hotkeyR1,@hotkeyR2,false,'Vision: Player #8'    );

   SetHintStr(0 ,@str_panelHint_o,@hotkeyO1,@hotkeyO2,false,'Fog of war'           );
   SetHintStr(2 ,@str_panelHint_o,@hotkeyO1,@hotkeyO2,false,'Vision: All players'  );
   SetHintStr(3 ,@str_panelHint_o,@hotkeyO1,@hotkeyO2,false,'Vision: Player #1'    );
   SetHintStr(4 ,@str_panelHint_o,@hotkeyO1,@hotkeyO2,false,'Vision: Player #2'    );
   SetHintStr(5 ,@str_panelHint_o,@hotkeyO1,@hotkeyO2,false,'Vision: Player #3'    );
   SetHintStr(6 ,@str_panelHint_o,@hotkeyO1,@hotkeyO2,false,'Vision: Player #4'    );
   SetHintStr(7 ,@str_panelHint_o,@hotkeyO1,@hotkeyO2,false,'Vision: Player #5'    );
   SetHintStr(8 ,@str_panelHint_o,@hotkeyO1,@hotkeyO2,false,'Vision: Player #6'    );
   SetHintStr(9 ,@str_panelHint_o,@hotkeyO1,@hotkeyO2,false,'Vision: Player #7'    );
   SetHintStr(10,@str_panelHint_o,@hotkeyO1,@hotkeyO2,false,'Vision: Player #8'    );


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

procedure language_rus;
var t: shortstring;
    p: byte;
begin
  {str_bool[false]       := tc_red +'нет';
  str_bool[true ]       := tc_lime+'да';

  str_ptype_AI           := 'ИИ';
  str_ptype_cheater        := 'читер';

  str_MMap              := 'КАРТА';
  str_MPlayers          := 'ИГРОКИ';
  str_MObjectives       := 'ЗАДАЧИ';
  str_MServers          := 'СЕРВЕРЫ';

  str_menu_Campaings    := 'КАМПАНИИ';
  str_menu_Scirmish     := 'СХВАТКА';
  str_menu_LoadGame     := 'ЗАГРУЗИТЬ ИГРУ';
  str_menu_savegame     := 'СОХРАНИТЬ ИГРУ';
  str_menu_LoadReplay   := 'ЗАГРУЗИТЬ ЗАПИСЬ';
  str_menu_Settings     := 'НАСТРОЙКИ';
  str_menu_AboutGame    := 'О ИГРЕ';
  str_menu_Surrender    := 'СДАТЬСЯ';
  str_menu_Back         := 'НАЗАД';
  str_menu_Exit         := 'ВЫХОД';

  str_map_typel[mapt_steppe ] := tc_gray  +'Степь';
  str_map_typel[mapt_canyon ] := tc_blue  +'Каньон';
  str_map_typel[mapt_clake  ] := tc_aqua  +'Озеро';
  str_map_typel[mapt_ilake  ] := tc_green +'Озеро с островами';
  str_map_typel[mapt_island ] := tc_yellow+'Остров';
  str_map_typel[mapt_shore  ] := tc_orange+'Берег моря';
  str_map_typel[mapt_sea    ] := tc_red   +'Море';
  str_map_size          := 'Размер: ';
  str_map_sym           := 'Симм.: ';
  str_map_syml[maps_none ]:= 'нет';
  str_map_syml[maps_point]:= 'точка';
  str_map_syml[maps_lineV]:= 'линия |';
  str_map_syml[maps_lineh]:= 'линия -';
  str_map_syml[maps_lineL]:= 'линия \';
  str_map_syml[maps_lineR]:= 'линия /';
  str_map               := 'Карта';
  str_players           := 'Игроки';
  str_map_random           := 'Случайная карта';
  str_menu_MusicVolume          := 'Громкость музыки';
  str_menu_SoundVolume          := 'Громкость звуков';
  str_menu_ScrollSpeed         := 'Скорость пр.';
  str_menu_MouseScroll         := 'Прокр. мышью';
  str_fullscreen        := 'В окне';
  str_menu_PlayerName            := 'Имя игрока';
  str_menu_maction           := 'Действие на правый клик';
  str_menu_mactionl[true ]   := tc_lime+'движение'+tc_default;
  str_menu_mactionl[false]   := tc_lime+'движ.'   +tc_default+'+'+tc_red+'атака'+tc_default;
  str_racel[r_random]   := tc_default+'ЛЮБАЯ';
  str_observer          := 'ЗРИТЕЛЬ';
  str_pause             := 'Пауза';
  str_win               := 'ПОБЕДА!';
  str_lose              := 'ПОРАЖЕНИЕ!';
  str_gsunknown         := 'Неизвестный статус!';
  str_msg_GameSaved            := 'Игра сохранена';
  str_repend            := 'Конец записи!';
  str_reperror          := 'Ошибка при чтении файла!';
  str_save              := 'Сохранить';
  str_load              := 'Загрузить';
  str_delete            := 'Удалить';
  str_error_FileExists  := 'Файл не'+tc_nl3+'существует!';
  str_error_OpenFile  := 'Неполучилось'+tc_nl3+'открыть файл!';
  str_error_WrongData := 'Неправильный'+tc_nl3+'размер файла!';
  str_error_WrongVersion  := 'Неправильная'+tc_nl3+'версия файла!';
  str_uiHint_Time              := 'Время: ';
  str_panelHint_menu              := 'Меню';
  str_msg_PlayerDefeated        := ' уничтожен';
  str_msg_PlayerLeave             := ' покинул игру';
  str_msg_PlayerSurrender       := ' сдается';
  str_uiHint_InvTime          := 'Волна #';
  str_uiHint_InvLimit            := 'Армия монстров: ';
  str_play              := 'Проиграть';
  str_replay            := 'ЗАПИСЬ';
  str_replay_status     := 'СТАТУС';
  str_menu_ReplayName       := 'Название записи';
  str_cmpdif            := 'Сложность: ';
  str_waitsv            := 'Ожидание сервера...';
  str_goptions          := 'ПАРАМЕТРЫ ИГРЫ';
  str_menu_server            := 'СЕРВЕР';
  str_client            := 'КЛИЕНТ';
  str_menu_chat         := 'ЧАТ(ВСЕ ИГРОКИ)';
  str_chat_all          := 'ВСЕ:';
  str_chat_allies       := 'СОЮЗНИКИ:';
  str_menu_RandomScirmish           := 'Случайная битва';
  str_menu_Apply             := 'применить';
  str_menu_AISlots           := 'Заполнить пустые слоты';
  str_menu_ResolutionWidth       := 'Разрешение (ширина)';
  str_menu_ResolutionHeight      := 'Разрешение (высота)';
  str_menu_language          := 'Язык интерфейса';
  str_uhint_requirements      := 'Требования: ';
  str_uhint_req               := 'Треб.: ';
  str_uiHint_UGroups            := 'Отряды: ';
  str_panelHint_all               := 'Все';
  str_uhint_uprod             := tc_lime+'Создается в: '+tc_default;
  str_uhint_bprod             := tc_lime+'Чем может быть построен: '     +tc_default;
  str_menu_ColoredShadow     := 'Цветные тени';
  str_uiHint_KotHTime          := 'Время до захвата центра: ';
  str_uiHint_KotHTimeAct      := 'Время до активации центральной зоны: ';
  str_uiHint_KotHWinner        := ' - Царь Горы!';
  str_menu_DeadObservers     := 'Наблюдатель после поражения';
  str_menu_FPS               := 'Показать FPS';
  str_menu_APM               := 'Показать APM';
  str_uhint_ability           := 'Специальная способность: ';
  str_uhint_transformation    := 'превращение в ';
  str_uhint_UnitLevel       := 'Улучшения: ';
  str_demons            := 'демоны и зомби';
  str_except            := 'кроме';
  str_splashresist      := 'Невосприимчив к взрывной волне';
  str_uhint_TargetLimit       := 'лимит цели';
  str_menu_NextTrack         := 'Следующий трек';
  str_msg_PlayerPaused      := 'игрок приостановил игру';
  str_msg_PlayerResumed     := 'игрок возобновил игру';
  str_Address           := 'Адрес';

  str_uhint_builder           := 'Строитель';
  str_uhint_barrack           := 'Производит юнитов';
  str_uhint_smith             := 'Исследует улучшения и апгрейды';
  str_uhint_IncEnergyLevel    := 'Увеличивает уровень энергии';
  str_uhint_CanRebuildTo      := 'Можно перестроить в ';
  str_uhint_UnitArming        := 'Вооружение/Способности: ';
  str_uhint_hits              := 'Здоровье: ';
  str_uhint_srange            := 'Базовый радиус обзора: ';

  str_weapon_melee      := 'ближний бой';
  str_weapon_ranged     := 'дальний бой';
  str_weapon_zombie     := '+зомбификация';
  str_weapon_ressurect  := 'воскрешение';
  str_weapon_heal       := 'лечение/ремонт';
  str_weapon_spawn      := 'порождение';
  str_weapon_suicide    := 'самоубийство';
  str_weapon_targets    := 'цели: ';
  str_weapon_damage     := 'воздействие';

  str_uiWarn_CantBuild        := 'Нельзя строить здесь';
  str_uiWarn_NeedEnergy       := 'Необходимо больше энергии';
  str_uiWarn_CantProd         := 'Невоможно произвести это';
  str_uiWarn_CheckReqs        := 'Проверьте требования';
  str_uiWarn_CantExecute      := 'Невозвможно выполнить приказ';
  str_advanced          := 'Улучшенный ';
  str_uiWarn_UnitPromoted     := 'Юнит улучшен';
  str_uiWarn_UpgradeComplete  := 'Исследование завершено';
  str_uiWarn_BuildingComplete := 'Постройка завершена';
  str_uiWarn_UnitComplete     := 'Юнит готов';
  str_uiWarn_UnitAttacked     := 'Юнит атакован';
  str_uiWarn_BaseAttacked     := 'База атакована';
  str_uiWarn_AlliesAttacked   := 'Наши союзники атакованы';
  str_uiWarn_MaxLimitReached  := 'Достигнут максимальный размер армии';
  str_uiWarn_NeedMoreBuilders:= 'Необходимо больше строителей';
  str_uiWarn_ProductionBusy   := 'Все производства заняты';
  str_uiWarn_CantRebuild     := 'Невозможно перестроить/улучшить';
  str_uiWarn_NeedMoreProd      := 'Негде производить это';
  str_uiWarn_MaximumReached    := 'Достигнут максимум';
  str_uiWarn_MapMark           := ' поставил отметку на карте';

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

  str_menu_PlayerSlots[pss_closed  ]:='закрыто';
  str_menu_PlayerSlots[pss_observer]:='зритель';
  str_menu_PlayerSlots[pss_opened  ]:='открыто';
  str_menu_PlayerSlots[pss_ready   ]:='готов';
  str_menu_PlayerSlots[pss_nready  ]:='не готов';
  str_menu_PlayerSlots[pss_swap    ]:='на этот слот';
  for p:=pss_AI_1 to pss_AI_11 do
  str_menu_PlayerSlots[p]:=ai_name(p-pss_AI_1+1);

  str_teams[0]          := str_observer;
  for p:=1 to MaxPlayers do
  str_teams[p]          := 'ком. '+b2s(p);

  str_menu_PanelPos          := 'Положение игровой панели';
  str_menu_PanelPosl[0]      := tc_lime  +'слева' +tc_default;
  str_menu_PanelPosl[1]      := tc_orange+'справа'+tc_default;
  str_menu_PanelPosl[2]      := tc_yellow+'вверху'+tc_default;
  str_menu_PanelPosl[3]      := tc_aqua  +'внизу' +tc_default;

  str_menu_unitHBar             := 'Полоски здоровья';
  str_menu_unitHBarl[0]         := tc_lime  +'выбранные'+tc_default+'+'+tc_red+'поврежд.'+tc_default;
  str_menu_unitHBarl[1]         := tc_aqua  +'всегда'   +tc_default;
  str_menu_unitHBarl[2]         := tc_orange+'только '  +tc_lime+'выбранные'+tc_default;

  str_menu_PlayersColor            := 'Цвета игроков';
  str_menu_PlayersColorl[0]        := tc_white +'по умолчанию'+tc_default;
  str_menu_PlayersColorl[1]        := tc_lime  +'свои '+tc_yellow+'союзники '+tc_red+'враги'+tc_default;
  str_menu_PlayersColorl[2]        := tc_white +'свои '+tc_yellow+'союзники '+tc_red+'враги'+tc_default;
  str_menu_PlayersColorl[3]        := tc_purple+'команды'+tc_default;
  str_menu_PlayersColorl[4]        := tc_white +'свои '+tc_purple+'команды'+tc_default;

  str_menu_StartBase            := 'Количество строителей на старте';

  str_menu_FixedStarts           := 'Фиксированные старты';

  str_menu_GameMode            := 'Режим игры';
  str_emnu_GameModel[gm_scirmish]:= tc_lime  +'Схватка'           +tc_default;
  str_emnu_GameModel[gm_4x4     ]:= tc_orange+'3x3'               +tc_default;
  str_emnu_GameModel[gm_2x2x2x2   ]:= tc_yellow+'2x2x2'             +tc_default;
  str_emnu_GameModel[gm_capture ]:= tc_aqua  +'Захват точек'      +tc_default;
  str_emnu_GameModel[gm_invasion]:= tc_blue  +'Вторжение'         +tc_default;
  str_emnu_GameModel[gm_KotH    ]:= tc_purple+'Царь горы'         +tc_default;
  str_emnu_GameModel[gm_royale  ]:= tc_red   +'Королевская битва' +tc_default;

  str_menu_Generators        := 'Генераторы';
  str_menu_Generatorsl[0]    := 'свои';
  str_menu_Generatorsl[1]    := 'свои,без новых строит.';
  str_menu_Generatorsl[2]    := 'нейтральн.(5 мин.)';
  str_menu_Generatorsl[3]    := 'нейтральн.(10 мин.)';
  str_menu_Generatorsl[4]    := 'нейтральн.(15 мин.)';
  str_menu_Generatorsl[5]    := 'нейтральн.(20 мин.)';
  str_menu_Generatorsl[6]    := 'нейтральн.(бескон.)';

  str_menu_ReplayStatel[rpls_state_none ]:=           'ВЫКЛ.';
  str_menu_ReplayStatel[rpls_state_write]:= tc_yellow+'ЗАПИСЬ';
  str_menu_ReplayStatel[rpls_state_read ]:= tc_lime  +'ВОСПРОИЗВЕДЕНИЕ';

  str_menu_ready             := 'готов';
  str_menu_nready            := 'не готов';
  str_udpport           := 'UDP порт:';
  str_svup[false]       := 'Включить сервер';
  str_svup[true ]       := 'Выключить сервер';
  str_connect[false]    := 'Подключится';
  str_connect[true ]    := 'Отключится';
  str_replay_Quality    := 'Размер файла/качество';
  str_net_Quality       := 'Сет.трафик/Обновление юнитов';
  str_menu_connecting        := 'Соединение...';
  str_netsearching      := 'Поиск серверов...';
  str_menu_LANSearch         := 'Поиск серверов в локальной сети';
  str_error_WrongVersion      := 'Другая версия!';
  str_error_ServerFull        := 'Нет мест!';
  str_error_GameStarted       := 'Игра началась!';

  str_panelHint_Tab[0]         := 'Здания';
  str_panelHint_Tab[1]         := 'Юниты';
  str_panelHint_Tab[2]         := 'Исследования';
  str_panelHint_Tab[3]         := 'Запись';

  str_panelHint_Common[0]         := 'Меню (' +tc_lime+'Esc'        +tc_default+')';
  str_panelHint_Common[2]         := 'Пауза ('+tc_lime+'Pause/Break'+tc_default+')';

  str_uiHint_Army         := 'Армия: ';
  str_uiHint_Energy       := 'Энергия: ';

  g_presets[gp_custom   ].gp_name:= 'свои настройки';
  MakeGamePresetsNames(@str_emnu_GameModel[0],@str_map_typel[0]);

  str_ability_name[ua_Teleport        ]:='Телепортация';
  str_ability_name[ua_UACScan         ]:='Сканирование';
  str_ability_name[ua_HTowerBlink     ]:='Скачок';
  str_ability_name[ua_UACStrike       ]:='Ракетный удар';
  str_ability_name[ua_HKeepBlink      ]:='Перемещение';
  str_ability_name[ua_RebuildInPoint  ]:='';
  str_ability_name[ua_HInvulnerability]:='Неуязвимость';
  str_ability_name[ua_SpawnLost       ]:='Выпустить Lost Soul';
  str_ability_name[ua_HellVision      ]:='Адское зрение';
  str_ability_name[ua_CCFly           ]:='Двигатели для полета';
  str_ability_unload                    :='Выгрузить';

  hintStrUID(UID_HKeep           ,'Адская Крепость'            ,'');
  hintStrUID(UID_HAKeep          ,'Великая Адская Крепость'    ,'');
  hintStrUID(UID_HGate           ,'Врата Демонов'              ,'');
  hintStrUID(UID_HSymbol         ,'Нечестивый Символ'          ,'');
  hintStrUID(UID_HASymbol        ,'Великий Нечестивый Символ'  ,'');
  hintStrUID(UID_HPools          ,'Инфернальные Омуты'         ,'');
  hintStrUID(UID_HTeleport       ,'Телепорт'                   ,'');
  hintStrUID(UID_HPentagram      ,'Пентаграмма Смерти'         ,'');
  hintStrUID(UID_HMonastery      ,'Монастырь Отчаяния'         ,'');
  hintStrUID(UID_HFortress       ,'Замок Проклятых'            ,'');
  hintStrUID(UID_HTower          ,'Сторожевая Башня'           ,'Защитное сооружение'                  );
  hintStrUID(UID_HTotem          ,'Тотем Ужаса'                ,'Продвинутое защитное сооружение'      );
  hintStrUID(UID_HAltar          ,'Алтарь Боли'                ,'');
  hintStrUID(UID_HCommandCenter  ,'Проклятый Командный Центр'  ,''          );
  hintStrUID(UID_HACommandCenter ,'Продвинутый Проклятый Командный Центр','');
  hintStrUID(UID_HBarracks       ,'Казармы Зомби'              ,''          );
  hintStrUID(UID_HEye            ,'Око Зла'                    ,''          );

  hintStrUID(UID_ZMedic         ,'Обычный Зомби'              ,'');
  hintStrUID(UID_ZEngineer       ,'Зомби Инженер'              ,'');
  hintStrUID(UID_ZSergant        ,'Зомби Сержант'              ,'');
  hintStrUID(UID_ZSSergant       ,'Зомби Старший Сержант'      ,'');
  hintStrUID(UID_ZCommando       ,'Зомби Коммандо'             ,'');
  hintStrUID(UID_ZAntiaircrafter ,'Зомби Зенитчик'             ,'');
  hintStrUID(UID_ZSiegeMarine    ,'Зомби Артиллерист'          ,'');
  hintStrUID(UID_ZFPlasmagunner  ,'Зомби Плазмаганнер'         ,'');
  hintStrUID(UID_ZBFGMarine      ,'Зомби Солдат с BFG'         ,'');

  hintStrUPID(upgr_hell_t1attack  ,'Адская Огневая Мощь'           ,'Увеличение урона от дальних атак всех Т1 юнитов и защитных сооружений');
  hintStrUPID(upgr_hell_uarmor    ,'Боевая Плоть'                  ,'Увеличение защиты всех адских юнитов'                                 );
  hintStrUPID(upgr_hell_barmor    ,'Каменные Стены'                ,'Увеличение защиты всех адских зданий'                                 );
  hintStrUPID(upgr_hell_mattack   ,'Когти и зубы'                  ,'Увеличение урона от ближних атак'                                     );
  hintStrUPID(upgr_hell_regen     ,'Регенерация Плоти'             ,'Восстановление здоровья всех адских юнитов'                           );
  hintStrUPID(upgr_hell_pains     ,'Болевой Порог'                 ,'Адские юниты реже испытывают болевой паралич'                         );
  hintStrUPID(upgr_hell_towers    ,'Демонические Призраки'         ,'Увеличение радиуса обзора и атаки для защитных сооружений'            );
  hintStrUPID(upgr_hell_HKTeleport,'Телепортация Адской Крепости'  ,'Заряд для способности Адской Крепости'                                );
  hintStrUPID(upgr_hell_paina     ,'Аура Разложения'               ,'Адская крепость наносит урон всем вражеских не-зданиям вокруг. Урон игнорирует броню юнитов');
  hintStrUPID(upgr_hell_buildr    ,'Увеличение Области Обзора Адской Крепости',''                                       );
  hintStrUPID(upgr_hell_extbuild  ,'Адаптивный Фундамент'          ,'Все здания, кроме телепорта и производящих юнитов можно строить на декорациях');
  hintStrUPID(upgr_hell_ghostm    ,'Призрачные Монстры'            ,'Pinky Demon может бегать по декорациям'                                       );

  hintStrUPID(upgr_hell_spectre   ,'Призраки'                      ,'Pinky Demon становиться невидимым'                                         );
  hintStrUPID(upgr_hell_vision    ,'Адское Зрение'                 ,'Увеличение области обзора и атаки всех адских юнитов'                      );
  hintStrUPID(upgr_hell_phantoms  ,'Фантомы'                       ,'Pain Elemental создает Фантомов вместо Lost Soul'                          );
  hintStrUPID(upgr_hell_t2attack  ,'Демоническое Оружие'           ,'Увеличение урона от дальних атак всех Т2 юнитов и защитных сооружений'     );
  hintStrUPID(upgr_hell_teleport  ,'Улучшение Телепорта'           ,'Уменьшение времени перезарядки Телепорта'                              );
  hintStrUPID(upgr_hell_rteleport ,'Обратная Телепортация'         ,'Юнитов можно перемещать обратно в Телепорт'                            );
  hintStrUPID(upgr_hell_heye      ,'Улучшение Ока Зла'             ,'Увеличение области обзора Ока Зла'                           );
  hintStrUPID(upgr_hell_totminv   ,'Невидимость Тотема Ужаса'      ,''                               );
  hintStrUPID(upgr_hell_bldrep    ,'Восстановление Зданий'         ,'Восстановление здоровья всех адских зданий'                   );
  hintStrUPID(upgr_hell_tblink    ,'Короткая Телепортация'         ,'Заряды для способности Адской Башни и Тотема Ужаса');
  hintStrUPID(upgr_hell_resurrect ,'Воскрешение'                   ,'Способность ArchVile'                    );
  hintStrUPID(upgr_hell_invuln    ,'Сферы Неуязвимости'            ,'Заряды для способности Алтаря Боли'      );


  hintStrUID(UID_UCommandCenter  ,'Командный Центр'            ,'');
  hintStrUID(UID_UACommandCenter ,'Продвинутый Командный Центр','');
  hintStrUID(UID_UBarracks       ,'Казармы'                    ,'');
  hintStrUID(UID_UFactory        ,'Фабрика'                    ,'');
  hintStrUID(UID_UGenerator      ,'Генератор'                  ,'');
  hintStrUID(UID_UAGenerator     ,'Продвинутый Генератор'      ,'');
  hintStrUID(UID_UWeaponFactory  ,'Завод Вооружений'           ,'');
  hintStrUID(UID_UGTurret        ,'Анти-наземная Турель'       ,'Анти-наземное защитное сооружение' );
  hintStrUID(UID_UATurret        ,'Анти-воздушная Турель'      ,'Анти-воздушное защитное сооружение');
  hintStrUID(UID_UTechCenter     ,'Научный Центр'              ,'');
  hintStrUID(UID_UComputerStation,'Компьютерная Станция'       ,'');
  hintStrUID(UID_URadar          ,'Радар'                      ,'Разведует карту');
  hintStrUID(UID_URMStation      ,'Станция Ракетного Залпа'    ,'');
  hintStrUID(UID_UMine           ,'Мина'                       ,'');

  hintStrUID(UID_Sergant         ,'Сержант'                ,'');
  hintStrUID(UID_SSergant        ,'Старший Сержант'        ,'');
  hintStrUID(UID_Commando        ,'Коммандо'               ,'');
  hintStrUID(UID_Antiaircrafter  ,'Зенитчик'               ,'');
  hintStrUID(UID_SiegeMarine     ,'Артиллерист'            ,'');
  hintStrUID(UID_FPlasmagunner   ,'Плазмаганнер'           ,'');
  hintStrUID(UID_BFGMarine       ,'Солдат с BFG'           ,'');
  hintStrUID(UID_Engineer        ,'Инженер'                ,'');
  hintStrUID(UID_Medic           ,'Медик'                  ,'');
  hintStrUID(UID_UACDron         ,'Дрон'                   ,'');
  hintStrUID(UID_UTransport      ,'Десантный корабль'      ,'');
  hintStrUID(UID_Terminator      ,'Терминатор'             ,'');
  hintStrUID(UID_Tank            ,'Танк'                   ,'');
  hintStrUID(UID_Flyer           ,'Истребитель'            ,'');
  hintStrUID(UID_APC             ,'БТР'                    ,'');


  hintStrUPID(upgr_uac_attack     ,'Улучшение Воружений'               ,'Увеличение урона от дальних атак всех юнитов и защитных сооружений');
  hintStrUPID(upgr_uac_uarmor     ,'Улучшение Пехотной Брони'          ,'Увеличение защиты всех юнитов из Казарм'                     );
  hintStrUPID(upgr_uac_barmor     ,'Бетонные Стены'                    ,'Увеличение защиты всех зданий'                               );
  hintStrUPID(upgr_uac_melee      ,'Продвинутые Инструменты'           ,'Увеличение эффективности ремонта Инженера и лечения Медика'  );
  hintStrUPID(upgr_uac_mspeed     ,'Легковесная Броня'                 ,'Увеличение скорости передвижения всех юнитов из Казарм'      );
  hintStrUPID(upgr_uac_ssgup      ,'Разрывные Пули'                    ,'Сержант, Старший Сержант и Терминатор наносят больше урона по ['+str_attr_bio+'].' );
  hintStrUPID(upgr_uac_towers     ,'Прожекторы'                        ,'Увеличение радиуса обзора и атаки для защитных сооружений'      );
  hintStrUPID(upgr_uac_CCFly      ,'Летные Двигатели Командного Центра','Командный Центр может летать'                                  );
  hintStrUPID(upgr_uac_ccturr     ,'Турель Командного Центра'          ,'Командный Центр может атаковать'                                );
  hintStrUPID(upgr_uac_buildr     ,'Увеличение Области Обзора Командного Центра',''                           );
  hintStrUPID(upgr_uac_extbuild   ,'Адаптивный Фундамент'              ,'Все здания, кроме производящих юнитов можно строить на декорациях');
  hintStrUPID(upgr_uac_soaring    ,'Антигравитационная Платформа'      ,'Дрон может перемещаться по декорациям'              );

  hintStrUPID(upgr_uac_botturret  ,'Протокол Трансформации Дрона'      ,'Дрон может превратиться в Анти-наземную Турель'    );
  hintStrUPID(upgr_uac_vision     ,'Улучшенные Визоры'                 ,'Увеличение области обзора и атаки всех юнитов'  );
  hintStrUPID(upgr_uac_commando   ,'Стелс-Технологии'                  ,'Коммандо становиться невидимым'                 );
  hintStrUPID(upgr_uac_airsp      ,'Осколочные Снаряды'                ,'Антивоздушные снаряды наносят урон по области'  );
  hintStrUPID(upgr_uac_mechspd    ,'Улучшеные Двигатели'               ,'Увеличение скорости передвижения юнитов из Фабрики'      );
  hintStrUPID(upgr_uac_mecharm    ,'Улучшение Технической Брони'       ,'Увеличение защиты всех юнитов из Фабрики'                );
  hintStrUPID(upgr_uac_lturret    ,'Лазерные Орудия'                   ,'Анти-наземное оружие для Истребителя'                    );
  hintStrUPID(upgr_uac_transport  ,'Улучшение Транспорта'              ,'Увеличение вместимости Десантного Корабля'               );
  hintStrUPID(upgr_uac_radar_r    ,'Улучшение Радара'                  ,'Увеличение области обзора Радара'            );
  hintStrUPID(upgr_uac_plasmt     ,'Анти-наземное Плазменное Орудие'   ,'Анти-['+str_attr_mech+'] орудие для Анти-наземной Турели');
  hintStrUPID(upgr_uac_turarm     ,'Дополнительное Бронирование'       ,'Дополнительная защита для турелей'              );
  hintStrUPID(upgr_uac_rstrike    ,'Ракетный Залп'                     ,'Заряды для способности Станции Ракетного Залпа' );


  hintStrAction(0 ,'Специальная способность'        );
  t:='Специальная способность в точке';
  hintStrAction(1 ,t);
  str_uiWarn_ReqpsabilityOrder:= 'Используйте приказ "'+t+'"!';
  hintStrAction(2 ,'Перестроить/Улучшить');
  t:='атаковать врагов';
  hintStrAction(3 ,'Двигаться, '       +t);
  hintStrAction(4 ,'Стоять, '          +t);
  hintStrAction(5 ,'Патрулировать, '   +t);
  t:='игнорировать врагов';
  hintStrAction(6 ,'Двигаться, '       +t);
  hintStrAction(7 ,'Стоять, '          +t);
  hintStrAction(8 ,'Патрулировать, '   +t);
  hintStrAction(9 ,'Отмена производства' );
  hintStrAction(10,'Выбрать всех боевых незанятых юнитов');
  hintStrAction(11,'Уничтожить'          );
  hintStrAction(12,'Поставить метку'     );
  hintStrAction(13,str_menu_maction           );

  hintStrReplay(0 ,'Включить/выключить ускоренный просмотр',false);
  hintStrReplay(1 ,'Левый клик: назад на 2 секунды ('                                 +tc_lime+'W'+tc_default+')'+tc_nl1+
                'Правый клик: назад на 10 секунд ('  +tc_lime+'Ctrl'+tc_default+'+'+tc_lime+'W'+tc_default+')'+tc_nl1+
                'Средний клик: назад на 1 минуту ('  +tc_lime+'Alt' +tc_default+'+'+tc_lime+'W'+tc_default+')',true  );
  hintStrReplay(2 ,'Левый клик: пропустить 2 секунды ('                               +tc_lime+'E'+tc_default+')'+tc_nl1+
                'Правый клик: пропустить 10 секунд ('+tc_lime+'Ctrl'+tc_default+'+'+tc_lime+'E'+tc_default+')'+tc_nl1+
                'Средний клик: пропустить 1 минуту ('+tc_lime+'Alt' +tc_default+'+'+tc_lime+'E'+tc_default+')',true  );
  hintStrReplay(3 ,'Пауза'                   ,false);
  hintStrReplay(4 ,'Камера игрока'           ,false);
  hintStrReplay(5 ,'Список игровых сообщений',false);
  hintStrReplay(6 ,'Туман войны'             ,false);
  hintStrReplay(8 ,'Все игроки'              ,false);
  hintStrReplay(9 ,'Игрок #1',false);
  hintStrReplay(10,'Игрок #2',false);
  hintStrReplay(11,'Игрок #3',false);
  hintStrReplay(12,'Игрок #4',false);
  hintStrReplay(13,'Игрок #5',false);
  hintStrReplay(14,'Игрок #6',false);

  hintStrObserver(0 ,'Туман войны',false);
  hintStrObserver(2 ,'Все игроки' ,false);
  hintStrObserver(3 ,'Игрок #1'   ,false);
  hintStrObserver(4 ,'Игрок #2'   ,false);
  hintStrObserver(5 ,'Игрок #3'   ,false);
  hintStrObserver(6 ,'Игрок #4'   ,false);
  hintStrObserver(7 ,'Игрок #5'   ,false);
  hintStrObserver(8 ,'Игрок #6'   ,false);     }


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

        writeln(f,'Hotkey: ',RemoveSpecChars(hotKeyCommon(_ucl,@hotkeyP1,@hotkeyP2)));
        writeln(f,'Categories/Attributes: ',RemoveSpecChars(txt_makeAttributeStr(nil,u)));
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

        if(_attack)then
        begin
           writeln(f,str_uhint_UnitArming);
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

        if(not _ukbuilding)and(not _ukmech)and(_painc>0)and(_painc_upgr_step>0)then
        upgrLine(upgr_hell_pains,'PainState threshold '+_i2s(_painc_upgr_step));

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

procedure language_Switch;
begin
  if(ui_language)
  then language_rus
  else language_ENG;
end;



