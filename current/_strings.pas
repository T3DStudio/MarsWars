
////////////////////////////////////////////////////////////////////////////////
//
//  COMMON TOOLS
//

// int ticks to secs
function it2s(r:integer):integer;
begin
   if(r>0)
   then it2s:=(r+fr_ifps) div fr_fps1
   else it2s:=0;
end;
// card ticks to secs
function ct2s(r:cardinal):cardinal;
begin
   if(r>0)
   then ct2s:=(r+fr_ifps) div fr_fps1
   else ct2s:=0;
end;
// int ticks to secs str
function ir2s(r:integer):shortstring;
begin
   if(r<=0)
   then ir2s:=''
   else ir2s:=i2s(it2s(r))
end;
// card ticks to secs str
function cr2s(r:cardinal):shortstring;
begin
   if(r<=0)
   then cr2s:=''
   else cr2s:=c2s(ct2s(r))
end;

function RemoveSpecChars(str:shortstring;letNewLine:boolean=true):shortstring;
var i:byte;
begin
   RemoveSpecChars:='';
   if(length(str)>0)then
     for i:=1 to length(str) do
     begin
        if(letNewLine)then
          if(str[i]=tc_nl1)
          or(str[i]=tc_nl2)
          or(str[i]=tc_nl3)
          then RemoveSpecChars+=#10;
        if not(str[i] in tc_SpecChars)then RemoveSpecChars+=str[i];
     end;
end;

function i2sSign(i:integer):shortstring;
begin
  if(i<0)
  then i2sSign:=    i2s(i)
  else i2sSign:='+'+i2s(i);
end;

function limit2s(limit,base:longint):shortstring; // limit 2 string
var fr:integer;
begin
   fr:=limit mod base;
   case fr of
   0  : limit2s:=i2s(limit div base);
   50 : limit2s:=i2s(limit div base)+'.5';
   25 : limit2s:=i2s(limit div base)+'.25';
   75 : limit2s:=i2s(limit div base)+'.75';
   else limit2s:=i2s(limit div base)+'.'+i2s(fr);
   end;
end;

function str_InputKeyName(key:cardinal;key_type:TInputKeyType):shortstring;
begin
   case key_type of
   ikt_keyboard: case key of
                 SDLK_LCtrl,
                 SDLK_RCtrl          : str_InputKeyName:='Ctrl';
                 SDLK_LAlt,
                 SDLK_RAlt           : str_InputKeyName:='Alt';
                 SDLK_LShift,
                 SDLK_RShift         : str_InputKeyName:='Shift';
                 else                  str_InputKeyName:=UpperCase(SDL_GetKeyName(key));
                 end;
   ikt_mouseb  : case key of
                 SDL_BUTTON_left     : str_InputKeyName:='Mouse left button';
                 SDL_BUTTON_right    : str_InputKeyName:='Mouse right button';
                 SDL_BUTTON_middle   : str_InputKeyName:='Mouse middle button';
                 else                  str_InputKeyName:='Mouse button #'+c2s(key);
                 end;
   ikt_mousew  : case key of
                 SDL_BUTTON_WHEELUP  : str_InputKeyName:='Mouse wheel up';
                 SDL_BUTTON_WHEELDOWN: str_InputKeyName:='Mouse wheel down';
                 else                  str_InputKeyName:='Mouse wheel #'+c2s(key);
                 end;
   else str_InputKeyName:='Unknown key_type';
   end;
end;


function str_MakeActionHotKey(action:byte):shortstring;
begin
   str_MakeActionHotKey:='';
   with input_actions[action] do
   begin
      if(ik_depend>0)then
        str_MakeActionHotKey:=str_MakeActionHotKey(ik_depend)+'+';

      str_MakeActionHotKey+=tc_lime+str_InputKeyName(ik_value,ik_type)+tc_default;
   end;
end;

function str_ProductionHotKey(uid:byte):shortstring;
begin
   if(uid<=ui_ButtonsNum)
   then str_ProductionHotKey:=input_actions[byte(iAct_SProd1+uid)].ik_str_HK
   else str_ProductionHotKey:='';
end;

procedure str_SetAbilityBaseHint(aid:byte;NAME,DESCR:shortstring);
begin
  with g_aids[aid] do
  begin
     ua_str_name    :=NAME;
     ua_str_Descript:=DESCR;
  end;
end;

procedure str_SetUnitBaseHint(uid:byte;NAME,DESCR:shortstring);
begin
   with g_uids[uid] do
   begin
      uid_str_name        :=NAME;
      uid_str_BaseDescript:=DESCR;
   end;
end;

procedure str_SetUpgrBaseHint(upid:byte;NAME,DESCR:shortstring);
begin
   with g_upids[upid] do
   begin
      upgr_str_Name    :=NAME;
      upgr_str_Descript:=DESCR;
      if(length(upgr_str_Descript)>0)then
        if(upgr_str_Descript[length(upgr_str_Descript)]<>'.')then upgr_str_Descript+='.';
   end;
end;

procedure str_MakeActionHint(action:byte;hint:shortstring);
var hk:shortstring;
begin
   hk:=input_actions[action].ik_str_HK;
   if(length(hk)>0)
   then str_action_hint[action]:=hint+' ('+hk+')'
   else str_action_hint[action]:=hint;
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
      if(uid in g_uids[i].uid_prod_Units    )then STRADD(@up,g_uids[i].uid_str_name,sep_comma);
      if(uid in g_uids[i].uid_prod_Buildings)then STRADD(@bp,g_uids[i].uid_str_name,sep_comma);
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
         player :=@g_gplayers[playeri];
         unit_ApplyUID(pu);
         hits:=-32000;
      end;
   end;
   str_UnitAttributes:='';
   with pu^  do
   with uid^ do
   begin
      if(hits>hits_fdead)then
       if(hits>0)
       then STRADD(@str_UnitAttributes,str_attr_alive    ,sep_comma)
       else STRADD(@str_UnitAttributes,str_attr_dead     ,sep_comma);

      if(uid_isbuilding)
      then STRADD(@str_UnitAttributes,str_attr_building  ,sep_comma)
      else STRADD(@str_UnitAttributes,str_attr_unit      ,sep_comma);
      if(uid_ismech)
      then STRADD(@str_UnitAttributes,str_attr_mech      ,sep_comma)
      else STRADD(@str_UnitAttributes,str_attr_bio       ,sep_comma);
      if(uid_islight)
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
        if(not uid_isbuilding)
        or(uid_isbuilding and (uid_isbarrack or uid_issmith))then STRADD(@str_UnitAttributes,str_attr_level+b2s(level+1),sep_comma);
      if(buffs[ub_Detect]>0)or(uid_isdetector)
      then STRADD(@str_UnitAttributes,str_attr_detector,sep_comma);
      if(buffs[ub_Invuln]>0)
      then STRADD(@str_UnitAttributes,str_attr_invuln,sep_comma)
      else
        if(buffs[ub_Pain]>0)
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
   for i:=0 to LastDamageModFactor do
    with g_DamageMods[dmod][i] do
     if(dm_Factor<>100)and(dm_TargetFlags>0)then
      STRADD(@str_DamageHint,'x'+limit2s(dm_Factor,100)+' '+BaseFlags2Str(dm_TargetFlags),sep_comma);
end;

function str_ReqNum2s(basename:shortstring;reqn:byte):shortstring;
begin
   str_ReqNum2s:=basename;
   if(reqn>1)then str_ReqNum2s+='(x'+b2s(reqn)+')';
end;

function AddReq(ruid,rupid:byte):shortstring;
begin
  AddReq:='';
  if(ruid >0)then STRADD(@AddReq,'"'+str_ReqNum2s(g_uids [ruid ].uid_str_name ,1)+'"' ,sep_comma);
  if(rupid>0)then STRADD(@AddReq,'"'+str_ReqNum2s(g_upids[rupid].upgr_str_Name,1)+'"' ,sep_comma);
  if(length(AddReq)>0)then AddReq:='{'+tc_yellow+str_hint_req+tc_default+AddReq+'}';
  //str_hint_requirements
end;

function str_RebuildName(uid:byte;levelup,quotes:boolean):shortstring;
begin
  if(levelup)
  then str_RebuildName:=g_uids[uid].uid_str_name+'['+str_attr_level+'+1]'
  else str_RebuildName:=g_uids[uid].uid_str_name;
  if(quotes)then str_RebuildName:='"'+str_RebuildName+'"';
end;

function str_GetAbilityShortDescript(aid:byte):shortstring;
begin
   str_GetAbilityShortDescript:='';
end;

function str_MakeUnitDefaultDescription(uid:byte;basedesc:shortstring;for_doc:boolean):shortstring;
begin
   str_MakeUnitDefaultDescription:='';
    with g_uids[uid] do
    begin
       if(not for_doc)then
       STRADD(@str_MakeUnitDefaultDescription,str_hint_hits+i2s(uid_MaxHits1),sep_sdot);
       STRADD(@str_MakeUnitDefaultDescription,str_hint_BaseSightR+i2s(uid_BaseSightR),sep_sdot);

       if(uid_isbuilder    )then STRADD(@str_MakeUnitDefaultDescription,str_hint_builder,sep_sdot);
       if(uid_isbarrack    )then STRADD(@str_MakeUnitDefaultDescription,str_hint_barrack,sep_sdot);
       if(uid_issmith      )then STRADD(@str_MakeUnitDefaultDescription,str_hint_smith  ,sep_sdot);
       if(uid_EnergyGen  >0)then STRADD(@str_MakeUnitDefaultDescription,str_hint_IncEnergyLevel+'('+tc_aqua+'+'+i2s(uid_EnergyGen)+tc_default+')',sep_sdot);
       {if(uid_rebuild_uid>0)and(uid_ability<>uab_RebuildInPoint)then
       begin
          STRADD(@str_MakeUnitDefaultDescription,
          str_hint_CanRebuildTo+
          str_RebuildName(uid_rebuild_uid,uid_rebuild_uid=uid,true)+
          AddReq(uid_rebuild_ruid,uid_rebuild_rupgr),sep_sdot );
       end; }
       //ua_str_name
       {if(uid_ability>0)then
       begin
          if(uid_ability=uab_RebuildInPoint)and(uid_rebuild_uid>0)
          then STRADD(@str_MakeUnitDefaultDescription,str_hint_Ability+str_hint_TransformTo+str_RebuildName(uid_rebuild_uid,uid=uid_rebuild_uid,true)+AddReq(uid_rebuild_ruid,uid_rebuild_rupgr),sep_sdot)
          else
            if(length(str_ability_name[uid_ability])>0)
            then STRADD(@str_MakeUnitDefaultDescription,str_hint_Ability+'"'+str_ability_name[uid_ability]+'"'+AddReq(uid_ability_ReqUID,uid_ability_ReqUpgr),sep_sdot);
       end;}

       if(uid_SplashResist)or(uid_ismech)then STRADD(@str_MakeUnitDefaultDescription,str_hint_SplashResist,sep_sdot);

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
    then instr:='['+str_attr_dead+tc_default+','+str_hint_Demons+'] '+str_hint_Except+' ['+g_uids[UID_Cyberdemon].uid_str_name+','
                                                                                          +g_uids[UID_Mastermind].uid_str_name+','
                                                                                          +g_uids[UID_ArchVile  ].uid_str_name+']'
    else
     if(tset= uids_demons)
     then instr:='['+str_hint_Demons+']'
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
           STRADD(@instr,g_uids[u].uid_str_name,sep_comma);
         if(length(instr)>0)then instr:='['+instr+']';
      end;
      if(exnum<3)then
      begin
         for u:=1 to 255 do
          if(u in exset)then
           STRADD(@exstr,g_uids[u].uid_str_name,sep_comma);
         if(length(exstr)>0)then exstr:=str_hint_Except+' ['+exstr+']';
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
  with uid_arms[wid] do
  begin
     BaseDmg:=0;
     ocount :=0;
     case aw_type of
     wpt_suicide   : if(uid_DeathMissile>0)then
                     begin
                        BaseDmg:=g_mids[uid_DeathMissile].mid_base_damage;
                        ocount:=1;
                     end
                     else exit;       //wpt_suicide
     wpt_missle    : begin
                     BaseDmg:=g_mids[aw_object_id].mid_base_damage;
                     if(aw_object_count>=0)
                     then ocount:=aw_object_count
                     else ocount:=2;
                     end;
     wpt_directdmg,
     wpt_directdmgZ,
     wpt_heal      : BaseDmg:=aw_object_count;
     end;
     if(aw_type<>wpt_suicide)then
     begin
        n:=0;
        for i:=0 to aw_reload do
          if(i in aw_ShotPoints)then n+=1;
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
       if(aw_FakeShotsN>0)
       then sps:=(fr_fps1*n/aw_reload)/aw_FakeShotsN
       else sps:=(fr_fps1*n/aw_reload);
     STRADD(@str_MakeWeaponDPS,'*'+Float2Str(sps),'');
  end;
end;

function str_MakeWeaponString(uid,wid:byte;docSTR:boolean):shortstring;
var
dmod_str:shortstring;
begin
  with g_uids[uid] do
   with uid_arms[wid] do
   begin
      str_MakeWeaponString:='';
      case aw_type of
      0             : exit;
      wpt_missle,
      wpt_directdmg,
      wpt_directdmgZ: if(aw_max_range<0)
                      then STRADD(@str_MakeWeaponString,'- '+str_uarm_melee    ,sep_scomma)
                      else STRADD(@str_MakeWeaponString,'- '+str_uarm_ranged   ,sep_scomma);
      wpt_resurect  :      STRADD(@str_MakeWeaponString,'- '+str_uarm_ressurect,sep_scomma);
      wpt_heal      :      STRADD(@str_MakeWeaponString,'- '+str_uarm_heal     ,sep_scomma);
      wpt_unit      :      STRADD(@str_MakeWeaponString,'- '+str_uarm_spawn+' "'+g_uids[aw_object_id].uid_str_name+'"',sep_scomma);
      wpt_suicide   :      STRADD(@str_MakeWeaponString,'- '+str_uarm_suicide  ,sep_scomma);
      end;

      if(aw_min_range>0)then
      STRADD(@str_MakeWeaponString,str_uarm_MinRange+i2s(aw_min_range),sep_scomma);

      if(aw_max_range=aw_srange)then
      begin
         STRADD(@str_MakeWeaponString,str_uarm_MaxRange+str_hint_SightR,sep_scomma);
      end
      else
        if(aw_max_range<aw_srange) // melee
        then STRADD(@str_MakeWeaponString,str_uarm_MaxRange+i2s(-aw_max_range),sep_scomma)
        else
          if(aw_max_range>=aw_fsr0)then  // relative srange
          begin
             if(aw_max_range<>aw_fsr)
             then STRADD(@str_MakeWeaponString,str_uarm_MaxRange+str_hint_SightR+i2sSign(aw_max_range-aw_fsr),sep_scomma)
             else STRADD(@str_MakeWeaponString,str_uarm_MaxRange+str_hint_SightR,sep_scomma);
          end
          else STRADD(@str_MakeWeaponString,str_uarm_MaxRange+i2s(aw_max_range),sep_scomma);  // absolute

      if(aw_type=wpt_directdmgZ)then
      STRADD(@str_MakeWeaponString,str_uarm_zombie,sep_scomma);

      STRADD(@str_MakeWeaponString,str_uarm_targets+str_WeaponTargets(aw_tar_Flags,aw_tar_uids),sep_scomma);

      STRADD(@str_MakeWeaponString,str_uarm_BaseImpact+' '+str_MakeWeaponDPS(uid,wid),sep_scomma);

      if(aw_type=wpt_missle)then
        with g_mids[aw_object_id] do
          if(mid_base_SplashR>0)then  STRADD(@str_MakeWeaponString,str_uarm_SplashDamageR+i2s(mid_base_SplashR),sep_scomma);

      if(aw_type=wpt_suicide)and(uid_DeathMissile>0)then
        with g_mids[uid_DeathMissile] do
          if(mid_base_SplashR>0)then  STRADD(@str_MakeWeaponString,str_uarm_SplashDamageR+i2s(mid_base_SplashR),sep_scomma);

      //if(length(str_uarm_PriorityL[aw_tar_prior])>0)then
     //   STRADD(@str_MakeWeaponString,str_uarm_Priority+str_uarm_PriorityL[aw_tar_prior],sep_scomma);

      if(aw_impact_upgr>0)then
        STRADD(@str_MakeWeaponString,str_uarm_Upgrade+g_upids[aw_impact_upgr].upgr_str_Name+'('+i2sSign(aw_impact_upgrStep)+')',sep_scomma);

      dmod_str:='';
      case aw_type of
      wpt_suicide   : if(uid_DeathMissile>0)then dmod_str:=str_DamageHint(uid_DeathMissile_dmod);
      wpt_missle,
      wpt_directdmg,
      wpt_directdmgZ: if(aw_impact_dmod>0)then dmod_str:=str_DamageHint(aw_impact_dmod);
      end;

      if(length(dmod_str)>0)then
        STRADD(@str_MakeWeaponString,dmod_str,str_uarm_Factor);

      STRADD(@str_MakeWeaponString,AddReq(aw_req_uid,aw_req_upgr),sep_scomma);

      if(docSTR)then str_MakeWeaponString:=RemoveSpecChars(str_MakeWeaponString);
   end;
end;

function str_makeUpgrCostHint(upid,curlvl:byte):shortstring;
var ENRG,
    TIME,
    INFO:shortstring;
    i   :byte;
begin
  with g_upids[upid] do
  begin
     ENRG:='';
     TIME:='';
     INFO:='';

     if(upgr_max<=1)or(upgr_mfrg)
     then curlvl:=1
     else
       if(curlvl>upgr_max)and(curlvl<255)then curlvl:=upgr_max;

     if(upgr_renerg>0)then
       if(curlvl<255)
       then ENRG:=tc_aqua +i2s(GetUpgradeEnergy(upid,curlvl))+tc_default
       else
         if(upgr_max>0)then
         begin
            for i:=1 to upgr_max do STRADD(@ENRG,i2s(GetUpgradeEnergy(upid,i)),'/');
            ENRG:=tc_aqua+ENRG+tc_default;
         end;
     if(upgr_time  >0)then
       if(curlvl<255)
       then TIME:=tc_white+i2s(GetUpgradeTime(upid,curlvl)div fr_fps1)+tc_default
       else
         if(upgr_max>0)then
         begin
            for i:=1 to upgr_max do STRADD(@TIME,i2s(GetUpgradeTime(upid,i)div fr_fps1),'/');
            TIME:=tc_white+TIME+tc_default;
         end;
     if(length(ENRG)>0)then STRADD(@INFO,ENRG,sep_comma);
     if(length(TIME)>0)then STRADD(@INFO,TIME,sep_comma);
     STRADD(@INFO,tc_orange+'x'+i2s(upgr_max)+tc_default,sep_comma);
     if(upgr_max>1)and(upgr_mfrg)then STRADD(@INFO,tc_red+'*'+tc_default,sep_comma);

     if(length(INFO)>0)
     then str_makeUpgrCostHint:='('+INFO+')'
     else str_makeUpgrCostHint:='';
  end;
end;

function str_hintUnitCost(uid:byte;pIHK:pshortstring=nil):shortstring;
begin
   str_hintUnitCost:='';
   with g_uids[uid] do
   begin
      if(pIHK<>nil)then
        if(length(pIHK^)>0)then
          STRADD(@str_hintUnitCost,pIHK^,sep_comma);
      if(uid_EnergyReq  >0)then STRADD(@str_hintUnitCost,tc_aqua +i2s(uid_EnergyReq  )+tc_default,sep_comma);
      if(uid_ProdTimeSec>0)then STRADD(@str_hintUnitCost,tc_white+i2s(uid_ProdTimeSec)+tc_default,sep_comma);
      STRADD(@str_hintUnitCost,tc_orange+limit2s(uid_LimitUse,MinUnitLimit)+tc_default,sep_comma);
   end;
   if(length(str_hintUnitCost)>0)then str_hintUnitCost:='('+str_hintUnitCost+')';
end;

function str_AbilityGetHintHK(aid,uipos:byte):shortstring;
begin
   str_AbilityGetHintHK:='';
   with g_aids[aid] do
     case ua_type of
     uat_notarget,
     uat_point,
     uat_UnitAny,
     uat_UnitOwn,
     uat_UnitAlly,
     uat_UnitEnemy: case uipos of
                    0: str_AbilityGetHintHK:=input_actions[iAct_Control_UAbility1].ik_str_HK;
                    1: str_AbilityGetHintHK:=input_actions[iAct_Control_UAbility2].ik_str_HK;
                    2: str_AbilityGetHintHK:=input_actions[iAct_Control_UAbility3].ik_str_HK;
                    end;
     end;
end;

function str_AbilityGetHintName(aid,uipos:byte):shortstring;
var HK:shortstring;
begin
   HK:=str_AbilityGetHintHK(aid,uipos);
   with g_aids[aid] do
   begin
      str_AbilityGetHintName:=ua_str_name;
      if(ua_mbrush_hint>0)then
        with g_uids[ua_mbrush_hint] do
          str_AbilityGetHintName+='"'+uid_str_name+'"';
   end;
   if(length(HK)>0)then
     str_AbilityGetHintName:=str_AbilityGetHintName+' ('+HK+')';
end;


procedure str_makeHints;
var
uid,arm: byte;
IENRG,
ILIMIT,
ITIME,
ITEMP  : shortstring;
begin
   // actions
   for uid:=0 to 255 do
     input_actions[uid].ik_str_HK:=str_MakeActionHotKey(uid);

   // units
   for uid:=0 to 255 do
     with g_uids[uid] do
     begin
        IENRG :='';
        ITIME :='';
        ILIMIT:='';
        ITEMP :='';

        ITEMP:=str_ProductionHotKey(uid_uibtn);
        if(length(ITEMP)>0)
        then uid_str_NameHK:=uid_str_Name+' ('+ITEMP+')'
        else uid_str_NameHK:=uid_str_Name;
        ITEMP :='';

        if(uid_EnergyReq  >0)then IENRG:=tc_aqua +i2s(uid_EnergyReq  )+tc_default;
        if(uid_ProdTimeSec>0)then ITIME:=tc_white+i2s(uid_ProdTimeSec)+tc_default;
        ILIMIT:=tc_orange+limit2s(uid_LimitUse,MinUnitLimit)+tc_default;
        if(length(IENRG )>0)then STRADD(@ITEMP,IENRG ,sep_comma);
        if(length(ILIMIT)>0)then STRADD(@ITEMP,ILIMIT,sep_comma);
        if(length(ITIME )>0)then STRADD(@ITEMP,ITIME ,sep_comma);
        uid_str_CostLimit   :='('+ITEMP+')';
        uid_str_DefaultAttr :=str_UnitAttributes(nil,uid);

        uid_str_Prod:='';
        ITEMP:=FindSourceProd(uid);
        if(length(ITEMP)>0)then
          if(uid_isbuilding)
          then uid_str_Prod:=str_hint_bprod+ITEMP
          else uid_str_Prod:=str_hint_uprod+ITEMP;

        uid_str_RebuildHint:='';

        ITEMP:='';
        if(uid_req_uid1>0)then STRADD(@ITEMP,str_ReqNum2s(g_uids [uid_req_uid1].uid_str_name ,uid_req_uid1n),sep_comma);
        if(uid_req_uid2>0)then STRADD(@ITEMP,str_ReqNum2s(g_uids [uid_req_uid2].uid_str_name ,uid_req_uid2n),sep_comma);
        if(uid_req_uid3>0)then STRADD(@ITEMP,str_ReqNum2s(g_uids [uid_req_uid3].uid_str_name ,uid_req_uid3n),sep_comma);
        if(uid_req_upgr>0)then STRADD(@ITEMP,str_ReqNum2s(g_upids[uid_req_upgr].upgr_str_Name,1            ),sep_comma);
        uid_str_Reqs:='';
        if(length(ITEMP)>0)then uid_str_Reqs+=tc_yellow+str_hint_requirements+tc_default+ITEMP;

        uid_str_FullDescript:=str_MakeUnitDefaultDescription(uid,uid_str_BaseDescript,false);

        uid_str_ArmsCommon:='';
        if(uid_CanAttack)then
        begin
           if(uid_arms_BonusAntiFlyRange     <>0)then STRADD(@uid_str_ArmsCommon,str_uarm_BonusAFlyR     +i2sSign(uid_arms_BonusAntiFlyRange     ),sep_scomma);
           if(uid_arms_BonusAntiGroundRange  <>0)then STRADD(@uid_str_ArmsCommon,str_uarm_BonusAGroundR  +i2sSign(uid_arms_BonusAntiFlyRange     ),sep_scomma);
           if(uid_arms_BonusAntiUnitRange    <>0)then STRADD(@uid_str_ArmsCommon,str_uarm_BonusAUnitR    +i2sSign(uid_arms_BonusAntiUnitRange    ),sep_scomma);
           if(uid_arms_BonusAntiBuildingRange<>0)then STRADD(@uid_str_ArmsCommon,str_uarm_BonusABuildingR+i2sSign(uid_arms_BonusAntiBuildingRange),sep_scomma);
        end;

        for arm:=0 to LastUnitArms do
          if(uid_CanAttack)
          then uid_str_Arms[arm]:=str_MakeWeaponString(uid,arm,false)
          else uid_str_Arms[arm]:='';
     end;

   // upgrades
   for uid:=0 to 255 do
     with g_upids[uid] do
     begin
        ITEMP:=str_ProductionHotKey(upgr_btni);
        if(length(ITEMP)>0)
        then upgr_str_NameHK:=upgr_str_Name+' ('+ITEMP+')'
        else upgr_str_NameHK:=upgr_str_Name;

        ITEMP:='';
        if(upgr_ruid  >0)then STRADD(@ITEMP,g_uids [upgr_ruid ].uid_str_name ,sep_comma);
        if(upgr_rupgr >0)then STRADD(@ITEMP,g_upids[upgr_rupgr].upgr_str_Name,sep_comma);
        if(length(ITEMP)>0)
        then upgr_str_Reqs:=tc_yellow+str_hint_requirements+tc_default+ITEMP
        else upgr_str_Reqs:='';
     end;

   // abilities
   for uid:=0 to 255 do
     with g_aids[uid] do
       if(ua_type<>uat_none)then
       begin
          //ITEMP
          ITEMP:='';
          if(ua_req_uid >0)then STRADD(@ITEMP,str_ReqNum2s(g_uids [ua_req_uid ].uid_str_name ,1),sep_comma);
          if(ua_req_upgr>0)then STRADD(@ITEMP,str_ReqNum2s(g_upids[ua_req_upgr].upgr_str_Name,1),sep_comma);
          ua_str_Reqs:='';
          if(length(ITEMP)>0)then ua_str_Reqs+=tc_yellow+str_hint_requirements+tc_default+ITEMP;

          ua_str_Common:='';
          case ua_type of
          uat_passive  : STRADD(@ua_str_Common,'Passive ability',sep_sdot);
          uat_notarget : STRADD(@ua_str_Common,'Active ability' ,sep_sdot);
          end;
          case ua_type of
          uat_passive  : ;
          uat_notarget : STRADD(@ua_str_Common,'Self-targeted'         ,sep_sdot);
          uat_point    : STRADD(@ua_str_Common,'Ground-targeted'       ,sep_sdot);
          uat_UnitAny  : STRADD(@ua_str_Common,'Any-unit-targeted'     ,sep_sdot);
          uat_UnitOwn  : STRADD(@ua_str_Common,'Own-unit-targeted'     ,sep_sdot);
          uat_UnitAlly : STRADD(@ua_str_Common,'Own&ally-unit-targeted',sep_sdot);
          uat_UnitEnemy: STRADD(@ua_str_Common,'Enemy-unit-targeted'   ,sep_sdot);
          end;
          if(ua_reload>0)then
          begin
             STRADD(@ua_str_Common,str_hint_reload+tc_aqua+ir2s(ua_reload)+tc_default+' sec',sep_sdot);
             if(ua_reload_upgr>0)then
               STRADD(@ua_str_Common,'Reload time reducing upgrade: '+g_upids[ua_reload_upgr].upgr_str_Name+'(-'+ir2s(ua_reload_upgrS)+')',sep_sdot);
          end;
          if(length(ua_str_Common)>0)then ua_str_Common+='.';
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

function str_JustifyBySpaces(src:shortstring;size:byte):shortstring;
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
   str_JustifyBySpaces:=src;
end;

procedure str_Trim(pstr:pshortstring);
var l:byte;
begin
   l:=length(pstr^);
   if(l=0)then exit;

   while(pstr^[1]=' ')do
   begin
      delete(pstr^,1,1);
      l:=length(pstr^);
      if(l=0)then exit;
   end;

   while(pstr^[l]=' ')do
   begin
      delete(pstr^,l,1);
      l:=length(pstr^);
      if(l=0)then exit;
   end;
end;

procedure str_analize(pstr,pspos,pepos,pendc,plen:pshortstring;ptextH:pinteger;plines_n,pmaxW:pbyte;MaxLineChars:byte);
var
strLen,
i,start,
lastSplitChar,
lastSplitChars,
chars  :byte;
charc  :char;
textH  :integer;
procedure AddLine(endChar:char);
begin
   if(pmaxW<>nil)then
     if(chars>pmaxW^)then
       pmaxW^:=chars;
   pspos^+=chr(start);
   pepos^+=chr(i    );
   plen^ +=chr(chars);
   pendc^+=endChar;
   start:=i+1;
   chars:=0;
   lastSplitChar:=0;
end;
begin
   pspos^:='';
   pepos^:='';
   plen^ :='';
   pendc^:='';
   plines_n^:=0;
   strLen:=length(pstr^);
   if(strLen=0)then exit;

   if(ptextH=nil)then ptextH:=@textH;
   ptextH^:=0;

   chars:=0;
   start:=1;
   lastSplitChar:=0;
   i:=0;
   while(i<strLen)do
   begin
      i+=1;
      charc:=pstr^[i];

      case charc of
      tc_nl1 : begin ptextH^+=txt_line_h1-font_w1;AddLine(charc);end;
      tc_nl2 : begin ptextH^+=txt_line_h2-font_w1;AddLine(charc);end;
      tc_nl3 : begin ptextH^+=txt_line_h3-font_w1;AddLine(charc);end;
      else
         if not(charc in tc_SpecChars)then
         begin
            case charc of
            ' ',
            '/',
            '\',
            ':',
            '-'  : begin
                      lastSplitChar :=i;
                      lastSplitChars:=chars;
                   end;
            ',',
            '.'  : if(i<255)and(i<strLen)then
                     if(pstr^[i+1]=' ')then
                     begin
                        lastSplitChar :=i;
                        lastSplitChars:=chars;
                     end;
            end;
            chars+=1;
            if(chars>=MaxLineChars)and(i<strLen)then
            begin
               ptextH^+=txt_line_h1-font_w1;
               if(lastSplitChar>0)then
               begin
                  i:=lastSplitChar;
                  chars:=lastSplitChars;
               end;
               AddLine(tc_nl1);
            end;
         end;
      end;
      if(i=strLen)then AddLine(#0);
   end;
   plines_n^:=length(plen^);
   ptextH^  +=plines_n^*font_w1;
end;

procedure str_AddToStrList(pslist:PTStringList;psln:pinteger;lineLen:integer;pmaxW:pbyte;newPara,Justify:boolean;newstr:shortstring);
var
lines_n,line :byte;
lines_spos,
lines_epos,
lines_endc,
lines_len :shortstring;
procedure AddToList(s:shortstring);
begin
   psln^+=1;
   setlength(pslist^,psln^);
   pslist^[psln^-1]:=s;
end;
begin
   if(psln^>0)and(newPara)then AddToList('');
   str_Trim(@newPara);

   str_analize(@newstr,@lines_spos,@lines_epos,@lines_endc,@lines_len,nil,@lines_n,pmaxW,lineLen);

   if(lines_n>0)then
     for line:=1 to lines_n do
       if(Justify)
       then AddToList(str_JustifyBySpaces(copy(newstr,ord(lines_spos[line]),ord(lines_epos[line])-ord(lines_spos[line])+1 ),lineLen))
       else AddToList(              copy(newstr,ord(lines_spos[line]),ord(lines_epos[line])-ord(lines_spos[line])+1          ));
end;

procedure cmp_AddPlot(mission:byte;newPara:boolean;text:shortstring);
begin
   str_AddToStrList(@str_camp_infol[mission],@str_camp_infon[mission],37,nil,newPara,true,text);
end;

function str_cmp_map(date,location,area:shortstring):shortstring;
begin
   str_cmp_map:=str_cmp_Date    +tc_nl3+
                  str_Center0(date    ,14)+tc_nl3+
                str_cmp_Location+tc_nl3+
                  str_Center0(location,14)+tc_nl3+
                str_cmp_Area    +tc_nl3+
                  str_Center0(area    ,14);
end;


