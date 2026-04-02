
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


function str_DateTime:shortstring;
var YY,MM,DD,H,M,S,MS:word;
function w2sZ(v,l:word):shortstring;
begin
   w2sZ:=w2s(v);
   if(l>0)then
     while(length(w2sZ)<l)do
       insert('0',w2sZ,1);
end;
begin
   DeCodeDate(Date,YY,MM,DD);
   DeCodeTime(Time,H,M,S,MS);
   str_DateTime:=w2sZ(YY,4)+'_'+w2sZ(MM,2)+'_'+w2sZ(DD,2)+' '+w2sZ(H,2)+'-'+w2sZ(M,2)+'-'+w2sZ(S,2)+'-'+w2sZ(MS,4);
end;

function str_CutEnd(s:shortstring;l:byte):shortstring;
var n:byte;
begin
   if(length(s)>l)then
   begin
      setlength(s,l);
      n:=0;
      while(l>0)and(n<3)do
      begin
         s[l]:='.';
         l-=1;
         n+=1;
      end;
   end;
   str_CutEnd:=s;
end;

function str_CutLast(s:shortstring;l:byte):shortstring;
var t:byte;
begin
   t:=length(s);
   if(t<=l)
   then str_CutLast:=s
   else str_CutLast:=copy(s,t-l+1,l);
end;

function str_GTick2Time(gtick:cardinal):shortstring;
var
s , m, h: cardinal;
ss,sm,sh:shortstring;
begin
   s:=gtick div fr_fps1;
   m:=s div 60;
   s:=s mod 60;
   h:=m div 60;
   m:=m mod 60;

   str_GTick2Time:='';
   if(h>0)then
   begin
      if(h<10)then sh:='0'+c2s(h) else sh:=c2s(h);
      str_GTick2Time:=sh+':';
   end;
   if(m<10)then sm:='0'+c2s(m) else sm:=c2s(m);
   if(s<10)then ss:='0'+c2s(s) else ss:=c2s(s);
   str_GTick2Time+=sm+':'+ss;
end;

function str_SpaceSize(str:shortstring;newSize:byte):shortstring;
var l,i:byte;
begin
   str_SpaceSize:=str;
   l:=0;
   i:=length(str_SpaceSize);
   while(i>0)do
   begin
      if not(str_SpaceSize[i] in tc_SpecChars)then l+=1;
      i-=1;
   end;
   if(newSize>l)then
   begin
      while(l<newSize)do
      begin
         l+=1;
         str_SpaceSize+=' ';
      end;
   end
   else
     if(newSize<l)then
       setlength(str_SpaceSize,newSize);
end;

procedure str_EndDot(pstr:pshortstring);
var t:byte;
begin
   t:=length(pstr^);
   if(t>0)then
     if(pstr^[t]<>'.')then pstr^+='.';
end;

function str_RemoveSpecChars(str:shortstring;letNewLine:boolean=true):shortstring;
var i:byte;
begin
   str_RemoveSpecChars:='';
   if(length(str)>0)then
     for i:=1 to length(str) do
     begin
        if(letNewLine)then
          if(str[i]=tc_nl1)
          or(str[i]=tc_nl2)
          or(str[i]=tc_nl3)
          then str_RemoveSpecChars+=#10;
        if not(str[i] in tc_SpecChars)then str_RemoveSpecChars+=str[i];
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
            '&',
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

procedure str_AddToStrList(pslist:PTUIStringList;lineLen:integer;newPara,Justify:boolean;newstr:shortstring);
var
lines_n,line :byte;
lines_spos,
lines_epos,
lines_endc,
lines_len :shortstring;
procedure AddToList(s:shortstring);
begin
   with pslist^ do
   begin
      slist_n+=1;
      setlength(slist_l,slist_n);
      slist_l[slist_n-1]:=s;
   end;
end;
begin
   if(pslist^.slist_n>0)and(newPara)then AddToList('');
   str_Trim(@newPara);

   str_analize(@newstr,@lines_spos,@lines_epos,@lines_endc,@lines_len,nil,@lines_n,@pslist^.slist_w,lineLen);

   if(lines_n>0)then
     for line:=1 to lines_n do
       if(Justify)
       then AddToList(str_JustifyBySpaces(copy(newstr,ord(lines_spos[line]),ord(lines_epos[line])-ord(lines_spos[line])+1 ),lineLen))
       else AddToList(                    copy(newstr,ord(lines_spos[line]),ord(lines_epos[line])-ord(lines_spos[line])+1          ));
end;

////////////////////////////////////////////////////////////////////////////////
//
//   STRING LISTs
//

procedure str_StringListClear(plist:PTUIStringList);
begin
   with plist^ do
   begin
      slist_n:=0;
      slist_w:=0;
      setlength(slist_l,slist_n);
   end;
end;
procedure str_StringListCopy(plistFrom,plistTo:PTUIStringList;add:boolean=false);
var i,o:integer;
begin
   case add of
   true : if(plistFrom^.slist_n>0)then
            with plistTo^ do
            begin
               if(slist_w<plistFrom^.slist_w)then
                 slist_w:=plistFrom^.slist_w;
               o:=slist_n;
               slist_n+=plistFrom^.slist_n;
               setlength(slist_l,slist_n);
               for i:=0 to  plistFrom^.slist_n-1 do
                 slist_l[o+i]:=plistFrom^.slist_l[i];
            end;
   false: with plistTo^ do
          begin
             str_StringListClear(plistTo);
             slist_n:=plistFrom^.slist_n;
             slist_w:=plistFrom^.slist_w;
             setlength(slist_l,slist_n);
             if(slist_n>0)then
               for i:=0 to slist_n-1 do
                 slist_l[i]:=plistFrom^.slist_l[i];
          end;
   end;
end;

////////////////////////////////////////////////////////////////////////////////
//
//   GAME STRINGS
//

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


function str_ActionHotKey(action:byte):shortstring;
begin
   str_ActionHotKey:='';
   with input_actions[action] do
   begin
      if(ik_depend>0)then
        str_ActionHotKey:=str_ActionHotKey(ik_depend)+'+';

      str_ActionHotKey+=tc_lime+str_InputKeyName(ik_value,ik_type)+tc_default;
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
     if(ua_mbrush_hint>0)then
       with g_uids[ua_mbrush_hint] do
         ua_str_name+='"'+uid_str_name+'"';
     ua_str_Descript:=DESCR;
     str_EndDot(@ua_str_Descript);
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
   with g_upgrs[upid] do
   begin
      upgr_str_Name    :=NAME;
      upgr_str_Descript:=DESCR;
      str_EndDot(@upgr_str_Descript);
   end;
end;

procedure str_SetActionBaseHint(action:byte;hint:shortstring);
var hk:shortstring;
begin
   hk:=input_actions[action].ik_str_HK;
   if(length(hk)>0)
   then str_action_hint[action]:=hint+' ('+hk+')'
   else str_action_hint[action]:=hint;
end;

function str_UpgradeNameForReq(upid:byte):shortstring;
begin
   str_UpgradeNameForReq:=str_hint_upgrade+' "'+g_upgrs[upid].upgr_str_Name+'"';
end;

function str_UpgradeNameBonus(upid:byte;bonus:integer):shortstring;
begin
   with g_upgrs[upid] do
     str_UpgradeNameBonus:='"'+upgr_str_Name+'"('+i2sSign(bonus)+')';
end;

function str_DocUpgradeLine(baseStr:shortstring;upid:byte;bonus:integer):shortstring;
begin
   str_DocUpgradeLine:='';
   if(upid>0)then
     str_DocUpgradeLine:=baseStr+str_UpgradeNameBonus(upid,bonus);
end;

function str_UnitsNamesList(list:TSoB):shortstring;
var i,c:byte;
begin
   str_UnitsNamesList:='';
   if(list=[])then exit;
   c:=0;
   for i in list do c+=1;
   for i in list do
   begin
      if(length(str_UnitsNamesList)=0)
      then str_UnitsNamesList:=g_uids[i].uid_str_name
      else
        if(c=1)
        then str_UnitsNamesList+=' '+str_and+' '+g_uids[i].uid_str_name
        else str_UnitsNamesList+=', '           +g_uids[i].uid_str_name;
      c-=1;
   end;
end;

function str_UnitProductBy(uid:byte):shortstring;
var i:byte;
ITEMP:shortstring;
begin
   str_UnitProductBy:='';
   ITEMP:='';
   for i:=0 to 255 do
     if(uid in g_uids[i].uid_prod_Units    )then
       STRADD(@ITEMP,g_uids[i].uid_str_name,sep_comma);
   if(length(ITEMP)>0)then STRADD(@str_UnitProductBy,ITEMP,sep_comma);

   ITEMP:='';
   for i:=0 to 255 do
     if(uid in g_uids[i].uid_prod_Buildings)then
       STRADD(@ITEMP,g_uids[i].uid_str_name,sep_comma);
   if(length(ITEMP)>0)then STRADD(@str_UnitProductBy,ITEMP,sep_comma);
end;

function str_UnitAttributes(pu:PTUnit;auid:byte):shortstring;
begin
   if(pu=nil)then
   begin
      pu:=@g_units[0];
      with pu^ do
      begin
         uidi   :=auid;
         playeri:=0;
         player :=@g_gplayers[playeri];
         unit_ApplyUID(pu);
         hits   :=hits_fdead-1;
      end;
   end;
   str_UnitAttributes:='';
   with pu^  do
   with uid^ do
   begin
      if(hits>hits_fdead)then
      if(hits>0                   )then STRADD(@str_UnitAttributes,str_attr_alive    ,sep_comma)
                                   else STRADD(@str_UnitAttributes,str_attr_dead     ,sep_comma);

      if(uid_isbuilding           )then STRADD(@str_UnitAttributes,str_attr_building ,sep_comma)
                                   else STRADD(@str_UnitAttributes,str_attr_unit     ,sep_comma);
      if(uid_ismech               )then STRADD(@str_UnitAttributes,str_attr_mech     ,sep_comma)
                                   else STRADD(@str_UnitAttributes,str_attr_bio      ,sep_comma);
      if(uid_islight              )then STRADD(@str_UnitAttributes,str_attr_light    ,sep_comma)
                                   else STRADD(@str_UnitAttributes,str_attr_heavy    ,sep_comma);
      if(isfly                    )then STRADD(@str_UnitAttributes,str_attr_fly      ,sep_comma)
                                   else STRADD(@str_UnitAttributes,str_attr_ground   ,sep_comma);
      if(level>0                  )then STRADD(@str_UnitAttributes,str_attr_level
                                                                        +b2s(level+1),sep_comma);
      if(buffs[ub_Heroic       ]>0)then STRADD(@str_UnitAttributes,str_attr_heroic   ,sep_comma);
      if(buffs[ub_Detector     ]>0)
      or(uid_isdetector           )then STRADD(@str_UnitAttributes,str_attr_detector ,sep_comma);
      if(buffs[ub_PainState    ]>0)then STRADD(@str_UnitAttributes,str_attr_stuned   ,sep_comma);
      if(buffs[ub_SphereInvuln ]>0)then STRADD(@str_UnitAttributes,str_attr_SInvuln  ,sep_comma);
      if(buffs[ub_SphereInvis  ]>0)then STRADD(@str_UnitAttributes,str_attr_SInvis   ,sep_comma);
      if(buffs[ub_SphereRDamage]>0)then STRADD(@str_UnitAttributes,str_attr_SRDamage ,sep_comma);
      if(buffs[ub_SphereDDamage]>0)then STRADD(@str_UnitAttributes,str_attr_SDDamage ,sep_comma);
      if(buffs[ub_SphereTurbo  ]>0)then STRADD(@str_UnitAttributes,str_attr_STurbo   ,sep_comma);
      if(buffs[ub_HellVision   ]>0)then STRADD(@str_UnitAttributes,str_attr_HVision  ,sep_comma);
      if(buffs[ub_Scaned       ]>0)then STRADD(@str_UnitAttributes,str_attr_Scaned   ,sep_comma);
      if(buffs[ub_DecayAura    ]>0)then STRADD(@str_UnitAttributes,str_attr_Decay    ,sep_comma);

      str_UnitAttributes:='['+str_UnitAttributes+tc_default+']';
   end;
end;

function str_BaseFlags2Str(flags:cardinal):shortstring;
function CheckFlags(f1,f2:cardinal;s1,s2:pshortstring;addifboth:boolean):boolean;
begin
   CheckFlags:=((flags and f1)>0)and((flags and f2)>0);
   if(addifboth)
   or( ((flags and f1)>0)<>((flags and f2)>0) )then
   begin
      if((flags and f1)>0)then STRADD(@str_BaseFlags2Str,s1^,sep_comma);
      if((flags and f2)>0)then STRADD(@str_BaseFlags2Str,s2^,sep_comma);
   end;
end;
begin
   str_BaseFlags2Str:='';

   CheckFlags(wtr_hits_d,wtr_hits_a+
                         wtr_hits_h  ,@str_attr_dead  ,@str_attr_alive   ,false);
   CheckFlags(wtr_unit  ,wtr_building,@str_attr_unit  ,@str_attr_building,false);
   CheckFlags(wtr_bio   ,wtr_mech    ,@str_attr_bio   ,@str_attr_mech    ,false);
   CheckFlags(wtr_light ,wtr_heavy   ,@str_attr_light ,@str_attr_heavy   ,false);
   CheckFlags(wtr_ground,wtr_fly     ,@str_attr_ground,@str_attr_fly     ,false);

   if(length(str_BaseFlags2Str)=0)then
   CheckFlags(wtr_ground,wtr_fly     ,@str_attr_ground,@str_attr_fly     ,true );

   if(length(str_BaseFlags2Str)>0)then str_BaseFlags2Str:='['+str_BaseFlags2Str+tc_default+']';
end;

function str_DamageMod(dmod:byte):shortstring;
var i:byte;
begin
   str_DamageMod:='';
   for i:=0 to LastDamageModFactor do
    with g_DamageMods[dmod][i] do
     if(dm_Factor<>100)and(dm_TargetFlags>0)then
      STRADD(@str_DamageMod,'x'+limit2s(dm_Factor,100)+' '+str_BaseFlags2Str(dm_TargetFlags),sep_comma);
end;

function str_ReqNum2s(basename:shortstring;reqn:byte):shortstring;
begin
   str_ReqNum2s:=basename;
   if(reqn>1)then str_ReqNum2s+='(x'+b2s(reqn)+')';
end;

function str_ReqFormat(ruid,rupid:byte):shortstring;
begin
  str_ReqFormat:='';
  if(ruid >0)then STRADD(@str_ReqFormat,'"'+str_ReqNum2s(g_uids [ruid ].uid_str_name ,1)+'"',sep_comma);
  if(rupid>0)then STRADD(@str_ReqFormat,    str_ReqNum2s(str_UpgradeNameForReq(rupid),1)    ,sep_comma);
  if(length(str_ReqFormat)>0)then str_ReqFormat:='{'+tc_yellow+str_hint_req+tc_default+str_ReqFormat+'}';
end;

function str_UnitRole(uid:byte):shortstring;
begin
   with g_uids[uid] do
   begin
      str_UnitRole:='';
      if(uid_isbuilder)then STRADD(@str_UnitRole,str_hint_builder,sep_scomma);
      if(uid_isbarrack)then STRADD(@str_UnitRole,str_hint_barrack,sep_scomma);
      if(uid_isforge  )then STRADD(@str_UnitRole,str_hint_forge  ,sep_scomma);
      if(length(str_UnitRole)>0)then str_UnitRole:=str_doc_Role+str_UnitRole;
   end;
end;

function str_Unit1LineDescript(uid:byte;basedesc:shortstring):shortstring;
begin
   str_Unit1LineDescript:='';
    with g_uids[uid] do
    begin
       STRADD(@str_Unit1LineDescript,str_doc_MaxHits+i2s(uid_MaxHits1)      ,sep_sdot);
       STRADD(@str_Unit1LineDescript,str_doc_BaseSightR+i2s(uid_SightR_Base),sep_sdot);
       STRADD(@str_Unit1LineDescript,str_UnitRole(uid)                      ,sep_sdot);

       if(uid_gen_EnergyLevel>0)then
         STRADD(@str_Unit1LineDescript,str_hint_IncEnergyLevel+'('+tc_aqua+'+'+i2s(uid_gen_EnergyLevel)+tc_default+')',sep_sdot);

       if(uid_isbuilding)
       or(uid_ismech)then STRADD(@str_Unit1LineDescript,str_hint_SplashResist,sep_sdot);

       STRADD(@str_Unit1LineDescript,basedesc,sep_sdot);
       str_EndDot(@str_Unit1LineDescript);
    end;
end;

function str_UnitArmTargets(tflags:cardinal;tset:TSoB):shortstring;
var u:byte;
inset:TSoB;
innum:byte;
exset:TSoB;
exnum:byte;
instr,
exstr:shortstring;
begin
   str_UnitArmTargets:='';
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
   then str_UnitArmTargets:=instr
   else
     if(length(exstr)>0)
     then str_UnitArmTargets:=str_BaseFlags2Str(tflags)+' '+exstr
     else str_UnitArmTargets:=str_BaseFlags2Str(tflags);
end;

function str_UnitArmDPS(uid,wid:byte):shortstring;
var BaseDmg,
    ocount : integer;
    i,n    : byte;
    sps    : single;
begin
  str_UnitArmDPS:='';
  with g_uids[uid] do
  with uid_arms[wid] do
  begin
     BaseDmg:=0;
     ocount :=0;
     case aw_type of
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
     begin
        n:=0;
        for i:=aw_reload downto 1 do
          if(i in aw_ShotPoints)then
            if (aw_reload=255) or not((i+1) in aw_ShotPoints)then n+=1;
     end;

     if(BaseDmg>0)then
     begin
        if(aw_type=wpt_heal)
        then STRADD(@str_UnitArmDPS,tc_lime+i2s(BaseDmg)+tc_default,'')
        else STRADD(@str_UnitArmDPS,tc_red +i2s(BaseDmg)+tc_default,'');

        if(ocount>1)
        then str_UnitArmDPS+='x'+i2s(ocount);
     end;

     if(aw_FakeShotsN>0)
     then sps:=(fr_fps1*n/aw_reload)/aw_FakeShotsN
     else sps:=(fr_fps1*n/aw_reload);
     STRADD(@str_UnitArmDPS,'*'+Float2Str(sps),'');
  end;
end;

function str_UnitArmLine(uid,wid:byte;docSTR:boolean):shortstring;
var
dmod_str:shortstring;
begin
   with g_uids[uid] do
   with uid_arms[wid] do
   begin
      str_UnitArmLine:='';
      case aw_type of
      0             : exit;
      wpt_missle,
      wpt_directdmg,
      wpt_directdmgZ: if(aw_max_range<0)
                      then STRADD(@str_UnitArmLine,'- '+str_uarm_melee    ,sep_scomma)
                      else STRADD(@str_UnitArmLine,'- '+str_uarm_ranged   ,sep_scomma);
      wpt_resurect  :      STRADD(@str_UnitArmLine,'- '+str_uarm_ressurect,sep_scomma);
      wpt_heal      :      STRADD(@str_UnitArmLine,'- '+str_uarm_heal     ,sep_scomma);
      wpt_unit      :      STRADD(@str_UnitArmLine,'- '+str_uarm_spawn+' "'+g_uids[aw_object_id].uid_str_name+'"',sep_scomma);
      //wpt_suicide   :      STRADD(@str_UnitArmLine,'- '+str_uarm_suicide  ,sep_scomma);
      end;

      if(aw_min_range>0)then
      STRADD(@str_UnitArmLine,str_uarm_MinRange+i2s(aw_min_range),sep_scomma);

      if(aw_max_range=aw_srange)then
      begin
         STRADD(@str_UnitArmLine,str_uarm_MaxRange+str_hint_SightR,sep_scomma);
      end
      else
        if(aw_max_range<aw_srange) // melee
        then STRADD(@str_UnitArmLine,str_uarm_MaxRange+i2s(-aw_max_range),sep_scomma)
        else
          if(aw_max_range>=aw_fsr0)then  // relative srange
          begin
             if(aw_max_range<>aw_fsr)
             then STRADD(@str_UnitArmLine,str_uarm_MaxRange+str_hint_SightR+i2sSign(aw_max_range-aw_fsr),sep_scomma)
             else STRADD(@str_UnitArmLine,str_uarm_MaxRange+str_hint_SightR,sep_scomma);
          end
          else STRADD(@str_UnitArmLine,str_uarm_MaxRange+i2s(aw_max_range),sep_scomma);  // absolute

      if(aw_type=wpt_directdmgZ)then
      STRADD(@str_UnitArmLine,str_uarm_zombie,sep_scomma);

      STRADD(@str_UnitArmLine,str_uarm_targets+str_UnitArmTargets(aw_tar_Flags,aw_tar_uids),sep_scomma);

      STRADD(@str_UnitArmLine,str_uarm_BaseImpact+' '+str_UnitArmDPS(uid,wid),sep_scomma);

      if(aw_type=wpt_missle)then
        with g_mids[aw_object_id] do
          if(mid_base_SplashR>0)then  STRADD(@str_UnitArmLine,str_uarm_SplashDamageR+i2s(mid_base_SplashR),sep_scomma);

      {if(aw_type=wpt_suicide)and(uid_DeathMissile>0)then
        with g_mids[uid_DeathMissile] do
          if(mid_base_SplashR>0)then  STRADD(@str_UnitArmLine,str_uarm_SplashDamageR+i2s(mid_base_SplashR),sep_scomma);  }

      if(aw_impact_upgr>0)then
        STRADD(@str_UnitArmLine,str_uarm_Upgrade+str_UpgradeNameBonus(aw_impact_upgr,aw_impact_upgrStep),sep_scomma);

      dmod_str:='';
      case aw_type of
      //wpt_suicide   : if(uid_DeathMissile>0)then dmod_str:=str_DamageMod(uid_DeathMissile_dmod);
      wpt_missle,
      wpt_directdmg,
      wpt_directdmgZ: if(aw_impact_dmod>0)then dmod_str:=str_DamageMod(aw_impact_dmod);
      end;

      if(length(dmod_str)>0)then
        STRADD(@str_UnitArmLine,dmod_str,str_uarm_Factor);

      STRADD(@str_UnitArmLine,str_ReqFormat(aw_req_uid,aw_req_upgr),sep_scomma);

      if(docSTR)then str_UnitArmLine:=str_RemoveSpecChars(str_UnitArmLine);
   end;
end;

function str_UpgradeCost(upid,curlvl:byte):shortstring;
var ENRG,
    TIME,
    INFO:shortstring;
    i   :byte;
begin
   with g_upgrs[upid] do
   begin
      ENRG:='';
      TIME:='';
      INFO:='';

      if(upgr_max<=1)
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

      if(length(INFO)>0)
      then str_UpgradeCost:='('+INFO+')'
      else str_UpgradeCost:='';
   end;
end;

function str_AbilityHotKey(aid,uipos:byte):shortstring;
begin
   str_AbilityHotKey:='';
   with g_aids[aid] do
     case ua_type of
     uat_notarget,
     uat_point,
     uat_UnitAny,
     uat_UnitOwn,
     uat_UnitAlly,
     uat_UnitEnemy: case uipos of
                    0: str_AbilityHotKey:=input_actions[iAct_Control_UAbility1].ik_str_HK;
                    1: str_AbilityHotKey:=input_actions[iAct_Control_UAbility2].ik_str_HK;
                    2: str_AbilityHotKey:=input_actions[iAct_Control_UAbility3].ik_str_HK;
                    end;
     end;
end;

function str_AbilityHintName(aid,uipos:byte):shortstring;
var HK:shortstring;
begin
   HK:=str_AbilityHotKey(aid,uipos);
   with g_aids[aid] do
     if(length(HK)>0)
     then str_AbilityHintName:=ua_str_name+' ('+HK+')'
     else str_AbilityHintName:=ua_str_name;
end;

function str_UIDCostLimit(uid:byte;halfProdTime:boolean=false):shortstring;
begin
   str_UIDCostLimit:='';
   with g_uids[uid] do
   begin
      if(uid_req_EnergyLevel>0)then STRADD(@str_UIDCostLimit,tc_aqua  +i2s(uid_req_EnergyLevel)          +tc_default,sep_comma);
      if(uid_req_HellPower  >0)then STRADD(@str_UIDCostLimit,tc_yellow+i2s(uid_req_HellPower  )          +tc_default,sep_comma);
      if(uid_req_UACLoot    >0)then STRADD(@str_UIDCostLimit,tc_lime  +i2s(uid_req_UACLoot    )          +tc_default,sep_comma);
                                    STRADD(@str_UIDCostLimit,tc_orange+limit2s(uid_LimitUse,MinUnitLimit)+tc_default,sep_comma);
      if(uid_ProdTimeSec    >0)then
                               if(halfProdTime)
                               then STRADD(@str_UIDCostLimit,tc_white +i2s(uid_ProdTimeSec div 2)        +tc_default,sep_comma)
                               else STRADD(@str_UIDCostLimit,tc_white +i2s(uid_ProdTimeSec      )        +tc_default,sep_comma);
      if(length(str_UIDCostLimit)>0)then str_UIDCostLimit:='('+str_UIDCostLimit+')';
   end;
end;

procedure str_makeAllHints;
var
uid,arm: byte;
ITEMP  : shortstring;
procedure AddLineUnitGameHint(line:shortstring);
begin
   if(length(line)>0)then
     with g_uids[uid] do
       str_AddToStrList(@uid_HintInGame,ui_HintLineLenUnit,false,false,line); //
end;
procedure AddLineUnitDocHint(line1:shortstring);
begin
   if(length(line1)>0)then
     with g_uids[uid] do
       str_AddToStrList(@uid_HintDoc,ui_DocLineLen1,false,false,tc_docbr+line1);
end;
procedure AddLineAbilityGameHint(line:shortstring);
begin
   if(length(line)>0)then
     with g_aids[uid] do
       str_AddToStrList(@ua_HintInGame,ui_HintLineLenUnit,false,false,tc_docbr+line); //
end;
function DocValI(val:integer;cchar:char=#0):shortstring;
begin
   if(val<=0)
   then DocValI:=str_YesNoG[false]
   else
   begin
      DocValI:=i2s(val);
      if(cchar<>#0)then DocValI:=cchar+DocValI+tc_default;
   end;
end;

begin
   /////////////////////////////////////////////////////////////////////////////
   //   ACTIONS
   for uid:=0 to 255 do
     input_actions[uid].ik_str_HK:=str_ActionHotKey(uid);

   /////////////////////////////////////////////////////////////////////////////
   //   UNITS
   for uid:=0 to 255 do
     with g_uids[uid] do
     if(uid_r>0)then
     begin
        // Basics
        ITEMP :='';

        uid_str_NameHK:=uid_str_Name;
        uid_str_HK:=str_ProductionHotKey(uid_uibtn);
        if(length(uid_str_HK)>0)then
          uid_str_NameHK+=' ('+uid_str_HK+')';

        uid_str_CostLimit:=str_UIDCostLimit(uid);

        uid_str_DefaultAttr:=str_UnitAttributes(nil,uid);

        uid_str_Prod:='';
        ITEMP:=str_UnitProductBy(uid);
        if(length(ITEMP)>0)then
          if(uid_isbuilding)
          then uid_str_Prod:=str_hint_bprod+ITEMP
          else uid_str_Prod:=str_hint_uprod+ITEMP;

        uid_str_RebuildHint:='';

        ITEMP:='';
        if(uid_req_uid1>0)then STRADD(@ITEMP,str_ReqNum2s(g_uids [uid_req_uid1].uid_str_name ,uid_req_uid1n),sep_comma);
        if(uid_req_uid2>0)then STRADD(@ITEMP,str_ReqNum2s(g_uids [uid_req_uid2].uid_str_name ,uid_req_uid2n),sep_comma);
        if(uid_req_uid3>0)then STRADD(@ITEMP,str_ReqNum2s(g_uids [uid_req_uid3].uid_str_name ,uid_req_uid3n),sep_comma);
        if(uid_req_upgr>0)then STRADD(@ITEMP,str_ReqNum2s(str_UpgradeNameForReq(uid_req_upgr),1            ),sep_comma);
        uid_str_Reqs:='';
        if(length(ITEMP)>0)then uid_str_Reqs+=tc_yellow+str_hint_requirements+tc_default+ITEMP;

        uid_str_1LineDescript:=str_Unit1LineDescript(uid,uid_str_BaseDescript);

        uid_str_ArmsCommon:='';
        if(uid_CanAttack)then
        begin
           if(uid_arms_BonusAntiFlyRange     <>0)then STRADD(@uid_str_ArmsCommon,str_uarm_BonusAFlyR     +i2sSign(uid_arms_BonusAntiFlyRange     ),sep_scomma);
           if(uid_arms_BonusAntiGroundRange  <>0)then STRADD(@uid_str_ArmsCommon,str_uarm_BonusAGroundR  +i2sSign(uid_arms_BonusAntiFlyRange     ),sep_scomma);
           if(uid_arms_BonusAntiUnitRange    <>0)then STRADD(@uid_str_ArmsCommon,str_uarm_BonusAUnitR    +i2sSign(uid_arms_BonusAntiUnitRange    ),sep_scomma);
           if(uid_arms_BonusAntiBuildingRange<>0)then STRADD(@uid_str_ArmsCommon,str_uarm_BonusABuildingR+i2sSign(uid_arms_BonusAntiBuildingRange),sep_scomma);
        end;

        str_StringListClear(@uid_HintInGame );
        str_StringListClear(@uid_HintDoc    );

        // Basic Game hint
        AddLineUnitGameHint(uid_str_NameHK      );
        AddLineUnitGameHint(uid_str_CostLimit   );
        AddLineUnitGameHint(uid_str_DefaultAttr );
        AddLineUnitGameHint(uid_str_1LineDescript);
        if(uid_CanAttack)then
        begin
           AddLineUnitGameHint(str_hint_UnitArming);
           for arm:=0 to LastUnitArms do
             AddLineUnitGameHint(str_UnitArmLine(uid,arm,false));
           AddLineUnitGameHint(uid_str_ArmsCommon );
        end;
        if(uid_HaveAbility)then
        begin
           AddLineUnitGameHint(str_hint_Abilities);
           if(uid_ability1>0)then AddLineUnitGameHint('- '+str_AbilityHintName(uid_ability1,255));
           if(uid_ability2>0)then AddLineUnitGameHint('- '+str_AbilityHintName(uid_ability2,255));
           if(uid_ability3>0)then AddLineUnitGameHint('- '+str_AbilityHintName(uid_ability3,255));
        end;
        AddLineUnitGameHint(uid_str_Reqs);
        AddLineUnitGameHint(uid_str_Prod);

        // Basic Doc hint //////////////////////////////////////////////////////
        AddLineUnitDocHint(str_doc_HotKey         +uid_str_HK        );
        AddLineUnitDocHint(str_doc_Attributes     );
        AddLineUnitDocHint(uid_str_DefaultAttr    );
        AddLineUnitDocHint(str_doc_MaxHits        +li2s(uid_MaxHits1));
        if(uid_req_EnergyLevel>0)then
        AddLineUnitDocHint(str_doc_ReqEnergy      +DocValI(uid_req_EnergyLevel,tc_aqua  ));
        if(uid_req_HellPower>0)then
        AddLineUnitDocHint(str_doc_ReqHellPower   +DocValI(uid_req_HellPower  ,tc_yellow));
        if(uid_req_UACLoot  >0)then
        AddLineUnitDocHint(str_doc_ReqUACLoot     +DocValI(uid_req_UACLoot    ,tc_lime  ));
        AddLineUnitDocHint(str_doc_Limit          +tc_orange+limit2s(uid_LimitUse,MinUnitLimit)+tc_default);
        AddLineUnitDocHint(str_doc_ProdTime       +DocValI(uid_ProdTimeSec    ,tc_white ));
        AddLineUnitDocHint(str_doc_Size           +i2s(uid_r)                );
        if(uid_MSpeed_Base>0)then
        AddLineUnitDocHint(str_doc_BaseMSpeed     +DocValI(uid_MSpeed_Base)  );
        AddLineUnitDocHint(str_doc_BaseSightR     +i2s(uid_SightR_Base)      );
        if(uid_Regen_Base>0)then
        AddLineUnitDocHint(str_doc_BaseRegen      +DocValI(uid_Regen_Base   ));
        if(not uid_isbuilding)then
        begin
           AddLineUnitDocHint(str_doc_PainC           +DocValI(uid_PainState_Base   ));
           AddLineUnitDocHint(str_doc_TransportSize   +DocValI(uid_TransportSize    ));
           if(uid_LevelBonusDamage>0)then
           AddLineUnitDocHint(str_doc_LevelDamageBonus+DocValI(uid_LevelBonusDamage ));
           if(uid_LevelBonusArmor>0)then
           AddLineUnitDocHint(str_doc_LevelArmorBonus +DocValI(uid_LevelBonusArmor  ));
           if(uid_PainState_Base>0)then
           AddLineUnitDocHint(str_doc_LevelPainSBonus +DocValI(uid_LevelBonusPainC  ));
        end;
        if(uid_TransportMax_Base>0)then
        AddLineUnitDocHint(str_doc_TransportCpst  +DocValI(uid_TransportMax_Base));
        AddLineUnitDocHint(str_hint_SplashResist  +': '+str_YesNoG[uid_isbuilding or uid_ismech]);
        if(uid_gen_EnergyLevel >0)then
        AddLineUnitDocHint(str_hint_IncEnergyLevel+': '+DocValI(uid_gen_EnergyLevel ,tc_aqua  ));
        if(uid_bounty_HellPower>0)then
        AddLineUnitDocHint(str_doc_BountyHellPower+': '+DocValI(uid_bounty_HellPower,tc_yellow));
        if(uid_bounty_UACLoot  >0)then
        AddLineUnitDocHint(str_doc_BountyUACLoot  +': '+DocValI(uid_bounty_UACLoot  ,tc_lime  ));
        if(uid_ZombieUID>0)then
        begin
           AddLineUnitDocHint(str_doc_ZombieUID   +'"'+g_uids[uid_ZombieUID].uid_str_name+'"');
           AddLineUnitDocHint(str_doc_ZombieHits  +i2s(uid_ZombieHits)       );
        end;
        if(uid_DeathUID>0)and(uid_DeathUIDn>0)then
        AddLineUnitDocHint(str_doc_DeathUnit+'"'+g_uids[uid_DeathUID].uid_str_name+'"x'+b2s(uid_DeathUIDn));

        AddLineUnitDocHint(str_UnitRole(uid));
        AddLineUnitDocHint(uid_str_Reqs     );
        AddLineUnitDocHint(uid_str_Prod     );
        if(length(uid_str_BaseDescript)>0)then
        AddLineUnitDocHint(str_doc_Description+uid_str_BaseDescript);

        if(uid_CanAttack)then
        begin
           AddLineUnitDocHint(tc_docbr);
           AddLineUnitDocHint(str_hint_UnitArming);
           for arm:=0 to LastUnitArms do
             AddLineUnitDocHint(str_UnitArmLine(uid,arm,false));
           AddLineUnitDocHint(uid_str_ArmsCommon);
        end;

        AddLineUnitDocHint(tc_docbr);
        AddLineUnitDocHint(str_ui_Tab[tab_Upgrades]+':');
        AddLineUnitDocHint(str_DocUpgradeLine('- '+str_doc_UpgrArmor    ,uid_Armor_upgr1      ,uid_Armor_upgrV       ));
        AddLineUnitDocHint(str_DocUpgradeLine('- '+str_doc_UpgrArmor    ,uid_Armor_upgr2      ,uid_Armor_upgrV       ));
        AddLineUnitDocHint(str_DocUpgradeLine('- '+str_doc_UpgrRegen    ,uid_Regen_upgr       ,BaseRegen1            ));
        AddLineUnitDocHint(str_DocUpgradeLine('- '+str_doc_UpgrSpeed    ,uid_MSpeed_upgr      ,uid_MSpeed_upgrV      ));
        AddLineUnitDocHint(str_DocUpgradeLine('- '+str_doc_UpgrPainS    ,uid_PainState_upgr   ,uid_PainState_upgrV   ));
        AddLineUnitDocHint(str_DocUpgradeLine('- '+str_doc_UpgrSightR   ,uid_SightR_upgr      ,uid_SightR_upgrV      ));
        AddLineUnitDocHint(str_DocUpgradeLine('- '+str_doc_UpgrTransport,uid_TransportMax_upgr,uid_TransportMax_upgrV));
     end;

   /////////////////////////////////////////////////////////////////////////////
   //  UPPGRADES
   for uid:=0 to 255 do
     with g_upgrs[uid] do
     begin
        ITEMP:=str_ProductionHotKey(upgr_btni);
        if(length(ITEMP)>0)
        then upgr_str_NameHK:=upgr_str_Name+' ('+ITEMP+')'
        else upgr_str_NameHK:=upgr_str_Name;

        ITEMP:='';
        if(upgr_ruid  >0)then STRADD(@ITEMP,g_uids [upgr_ruid ].uid_str_name ,sep_comma);
        if(upgr_rupgr >0)then STRADD(@ITEMP,g_upgrs[upgr_rupgr].upgr_str_Name,sep_comma);
        if(length(ITEMP)>0)
        then upgr_str_Reqs:=tc_yellow+str_hint_requirements+tc_default+ITEMP
        else upgr_str_Reqs:='';
     end;

   /////////////////////////////////////////////////////////////////////////////
   //  ABILITIES
   for uid:=0 to 255 do
     with g_aids[uid] do
       if(ua_type<>uat_none)then
       begin
          //ITEMP
          ITEMP:='';
          if(ua_req_uid >0)then STRADD(@ITEMP,str_ReqNum2s(g_uids [ua_req_uid ].uid_str_name ,1),sep_comma);
          if(ua_req_upgr>0)then STRADD(@ITEMP,str_ReqNum2s(str_UpgradeNameForReq(ua_req_upgr),1),sep_comma);
          ua_str_Reqs:='';
          if(length(ITEMP)>0)then ua_str_Reqs+=tc_yellow+str_hint_requirements+tc_default+ITEMP;

          ua_str_Common:='';
          ua_str_ReloadFactors:='';
          case ua_type of
          uat_passive  : STRADD(@ua_str_Common,str_ability_passive  ,sep_sdot);
          uat_notarget : STRADD(@ua_str_Common,str_ability_active   ,sep_sdot);
          end;
          case ua_type of
          uat_passive  : ;
          uat_notarget : STRADD(@ua_str_Common,str_ability_notarget ,sep_sdot);
          uat_point    : STRADD(@ua_str_Common,str_ability_point    ,sep_sdot);
          uat_UnitAny  : STRADD(@ua_str_Common,str_ability_UnitAny  ,sep_sdot);
          uat_UnitOwn  : STRADD(@ua_str_Common,str_ability_UnitOwn  ,sep_sdot);
          uat_UnitAlly : STRADD(@ua_str_Common,str_ability_UnitAlly ,sep_sdot);
          uat_UnitEnemy: STRADD(@ua_str_Common,str_ability_UnitEnemy,sep_sdot);
          end;

          if(ua_req_HellPower>0)then STRADD(@ua_str_Common,str_doc_ReqHellPower+tc_yellow+i2s(ua_req_HellPower)+tc_default,sep_sdot);
          if(ua_req_UACLoot  >0)then STRADD(@ua_str_Common,str_doc_ReqUACLoot  +tc_lime  +i2s(ua_req_UACLoot  )+tc_default,sep_sdot);
          if(ua_reload>0)then
          begin
             STRADD(@ua_str_Common,str_ability_reload+tc_aqua+ir2s(ua_reload)+tc_default+' '+str_hint_sec,sep_sdot);
             if(ua_rldDec_upgr>0)then
               STRADD(@ua_str_ReloadFactors,str_hint_upgrade+' "'+g_upgrs[ua_rldDec_upgr].upgr_str_Name+'"(-'+ir2s(ua_rldDec_upgrS)+')',sep_scomma);
             if(ua_rldDec_level>0)then
               STRADD(@ua_str_ReloadFactors,str_ability_rldDecByLevel+'(-'+ir2s(ua_rldDec_level)+')',sep_scomma);
             if(length(ua_str_ReloadFactors)>0)then ua_str_ReloadFactors:=str_ability_ReloadFactors+ua_str_ReloadFactors;
          end;
          str_EndDot(@ua_str_Common);

          str_StringListClear(@ua_HintInGame);

          AddLineAbilityGameHint(ua_str_Descript);
          AddLineAbilityGameHint(ua_str_Common);
          AddLineAbilityGameHint(ua_str_ReloadFactors);
          AddLineAbilityGameHint(ua_str_Reqs);

          if(ua_mbrush_hint>0)then
            with g_uids[ua_mbrush_hint] do
            begin
               AddLineAbilityGameHint(tc_docbr);
               AddLineAbilityGameHint(uid_str_name);
               AddLineAbilityGameHint(str_UIDCostLimit(ua_mbrush_hint,ua_mbrush_hint_HalfProdTime));
               AddLineAbilityGameHint(uid_str_1LineDescript);
            end;
       end;

   /////////////////////////////////////////////////////////////////////////////
   //   UNITS ABITIES (DOC)
   for uid:=0 to 255 do
     with g_uids[uid] do
     if(uid_r>0)then
     begin
        if(uid_HaveAbility)then
        begin
           AddLineUnitDocHint(tc_docbr);
           AddLineUnitDocHint(str_hint_Abilities);
           if(uid_ability1>0)then
             with g_aids[uid_ability1] do
             begin
                AddLineUnitDocHint('- '+str_AbilityHintName(uid_ability1,255)+': '+ua_str_Descript);
                AddLineUnitDocHint(ua_str_Common       );
                AddLineUnitDocHint(ua_str_ReloadFactors);
                AddLineUnitDocHint(ua_str_Reqs         );
             end;
           if(uid_ability2>0)then
             with g_aids[uid_ability2] do
             begin
                AddLineUnitDocHint('- '+str_AbilityHintName(uid_ability2,255)+': '+ua_str_Descript);
                AddLineUnitDocHint(ua_str_Common       );
                AddLineUnitDocHint(ua_str_ReloadFactors);
                AddLineUnitDocHint(ua_str_Reqs         );
             end;
           if(uid_ability3>0)then
             with g_aids[uid_ability3] do
             begin
                AddLineUnitDocHint('- '+str_AbilityHintName(uid_ability3,255)+': '+ua_str_Descript);
                AddLineUnitDocHint(ua_str_Common       );
                AddLineUnitDocHint(ua_str_ReloadFactors);
                AddLineUnitDocHint(ua_str_Reqs         );
             end;
        end;
        AddLineUnitDocHint(' ');
     end;
end;

procedure str_camp_SetMissionPlot(mission:byte;newPara:boolean;text:shortstring);
begin
   //str_AddToStrList(@str_camp_MissionInfo[mission],37,newPara,true,text);
end;

function str_camp_SetMapInfo(date,location,area:shortstring):shortstring;
begin
   str_camp_SetMapInfo:='';{str_cmp_Date    +tc_nl3+
                          str_Center0(date    ,14)+tc_nl3+
                        str_cmp_Location+tc_nl3+
                          str_Center0(location,14)+tc_nl3+
                        str_cmp_Area    +tc_nl3+
                          str_Center0(area    ,14)};
end;

procedure menu_set_hint(item,itemPos:byte;itemHint:shortstring);
begin
   menu_hint_pos[item]:=itemPos;
   str_menu_hint[item]:=itemHint;
end;


