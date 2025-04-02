
function sm_SModel2MWTexture(sm:PTMWSModel;animState:byte;dir,animStep:integer;stat:pbyte):PTMWTexture;  // sprite model 2 sprite
var dd,i:integer;
function aa3(b0,a,b1:integer):integer;
begin
   if(b1<=b0)
   then aa3:=b0
   else
    if(a<=b0)
    then aa3:=b0
    else aa3:=b0+(a mod (b1-b0+1));
end;
begin
   sm_SModel2MWTexture:=pspr_dummy;

   if(sm=nil)then exit;

   with sm^ do
   begin
      if(sm_listn<=0)then exit;

      if(sm_type=smt_fapc)
      then dd:=dir360(dir+12) div 23  // 0..15
      else dd:=dir360(dir+23) div 45; // 0..7

      if(sm_listi=0)
      then i:=0
      else
      case sm_type of
smt_effect  : if(animState=sms_death)
              then i:=animStep
              else i:=0;
smt_effect2 : if(animState=sms_death)
              then i:=animStep
              else i:=sm_listi;

smt_missile : if(animState=sms_death)
              then i:=8+animStep
              else i:=dd;

smt_buiding : case animState of
        sms_build: i:=mm3i(0,animStep,2);
        sms_death: exit;
              else i:=aa3(3,3+animStep,sm_listi);
              end;

smt_turret  : case animState of
        sms_build: i:=mm3i(0,animStep,2);
        sms_dattack,
        sms_mattack,
        sms_cast : i:=11+dd;
        sms_death: exit;
              else i:=3 +dd;
              end;

smt_turret2 : case animState of
        sms_build: i:=mm3i(0,animStep,2);
        sms_death: exit;
              else i:=3 +dd;
              end;

smt_lost    : case animState of
        sms_dready,
        sms_stand: i:=dd;
        sms_walk,
        sms_dattack,
        sms_mattack,
        sms_cast : i:=8 +dd;
        sms_pain : i:=16+dd;
        sms_death: i:=23+animStep;
              else exit;
              end;

smt_imp     : case animState of
        sms_dready,
        sms_stand,
        sms_walk : i:=4*dd+aa3(0,animStep,3);
        sms_dattack,
        sms_mattack,
        sms_cast : if(animStep>0)
                   then i:=dd+32
                   else i:=dd*4;
        sms_pain : i:=40+dd;
        sms_death: i:=48+animStep;
              else exit;
              end;

smt_zengineer:case animState of
        sms_stand,
        sms_walk : i:=4*dd+aa3(0,animStep,3);
        sms_death: i:=32+animStep;
              else i:=4*dd;
              end;

smt_zcommando:case animState of
        sms_stand,
        sms_walk : i:=4*dd+aa3(0,animStep,3);
        sms_cast,
        sms_mattack,
        sms_dready
                 : i:=32+dd;
        sms_dattack
                 : i:=40+dd;
        sms_pain : i:=48+dd;
        sms_death: i:=56+animStep;
              else exit;
              end;

smt_fmajor   :case animState of
        sms_dready,
        sms_dattack,
        sms_mattack,
        sms_cast : i:=8+dd;
        sms_death: exit;
              else i:=dd;
              end;
smt_flyer    :case animState of
        sms_dattack,
        sms_mattack,
        sms_cast : i:=8+dd;
        sms_death: exit;
              else i:=dd;
              end;
smt_caco     :case animState of
        sms_dready,
        sms_stand,
        sms_walk : i:=dd;
        sms_dattack,
        sms_mattack,
        sms_cast : if(animStep>0)
                   then i:=8+dd
                   else i:=dd;
        sms_pain : i:=16+dd;
        sms_death: i:=24+animStep;
              else exit;
              end;

smt_mmind    :case animState of
        sms_stand,
        sms_walk : i:=dd*6+aa3(0,animStep,5);
        sms_dready
                 : i:=48+dd;
        sms_dattack,
        sms_mattack,
        sms_cast : i:=56+dd;
        sms_pain : i:=64+dd;
        sms_death: i:=72+animStep;
              else exit;
              end;

smt_archno   :case animState of
        sms_stand,
        sms_walk : i:=dd*6+aa3(0,animStep,5);
        sms_dready,
        sms_dattack,
        sms_mattack,
        sms_cast : i:=48+dd;
        sms_pain : i:=56+dd;
        sms_death: i:=64+animStep;
              else exit;
              end;

smt_pain     :case animState of
        sms_dready,
        sms_stand,
        sms_walk : i:=dd*2+aa3(0,animStep,1);
        sms_dattack,
        sms_mattack,
        sms_cast : i:=16+dd;
        sms_pain : i:=24+dd;
        sms_death: i:=32+animStep;
              else exit;
              end;

smt_revenant :case animState of
        sms_dready,
        sms_stand,
        sms_walk : i:=dd*6+aa3(0,animStep,5);
        sms_mattack
                 : i:=48+dd;
        sms_dattack,
        sms_cast : i:=56+dd;
        sms_pain : i:=64+dd;
        sms_death: i:=72+animStep;
              else exit;
              end;

smt_mancubus :case animState of
        sms_stand,
        sms_walk : i:=dd*6+aa3(0,animStep,5);
        sms_dready
                 : i:=48+dd;
        sms_mattack,
        sms_dattack,
        sms_cast : i:=56+dd;
        sms_pain : i:=64+dd;
        sms_death: i:=72+animStep;
              else exit;
              end;

smt_arch     :case animState of
        sms_stand,
        sms_walk : i:=dd*6+aa3(0,animStep,5);
        sms_dready
                 : i:=48+dd;
        sms_dattack
                 : i:=56+dd;
        sms_mattack,
        sms_cast : i:=64+dd;
        sms_pain : i:=72+dd;
        sms_death: i:=80+animStep;
              else exit;
              end;

smt_apc      :case animState of
        sms_death: exit;
              else i:=dd*2+aa3(0,animStep,1);
              end;

smt_transport,
smt_fapc     :case animState of
        sms_death: exit;
              else i:=dd;
              end;

smt_marine0  :case animState of
        sms_build: i:=dd;
        sms_dready,
        sms_stand,
        sms_pain,
        sms_walk : i:=dd*4+aa3(0,animStep,3);
        sms_cast,
        sms_mattack,
        sms_dattack
                 : i:=32+dd;
        sms_death: i:=40+animStep;
              else exit;
              end;

smt_medic    :case animState of
        sms_build: i:=dd;
        sms_dready,
        sms_stand,
        sms_pain,
        sms_walk : i:=dd*4+aa3(0,animStep,3);
        sms_mattack
                 : i:=40+dd;
        sms_cast,
        sms_dattack
                 : i:=32+dd;
        sms_death: i:=48+animStep;
              else exit;
              end;

smt_commando :case animState of
        sms_build: i:=dd;
        sms_stand,
        sms_pain,
        sms_walk : i:=dd*4+aa3(0,animStep,3);
        sms_dready,
        sms_cast,
        sms_mattack
                 : i:=32+dd;
        sms_dattack
                 : i:=40+dd;
        sms_death: i:=48+animStep;
              else exit;
              end;

smt_tank     :case animState of
        sms_build: i:=dd;
        sms_dready,
        sms_stand,
        sms_pain,
        sms_walk : i:=dd*2+aa3(0,animStep,1);
        sms_cast,
        sms_mattack,
        sms_dattack
                 : if(animStep>0)
                   then i:=16+dd
                   else i:=dd*2;
              else exit;
              end;

smt_terminat :case animState of
        sms_build: i:=dd;
        sms_dready,
        sms_stand,
        sms_pain,
        sms_walk : i:=dd*4+aa3(0,animStep,3);
        sms_mattack,
        sms_cast : i:=32+dd;
        sms_dattack
                 : i:=40+dd;
              else exit;
              end;

      else i:=0;
      end;

      if(stat<>nil)then
      begin
         if(i<sm_listi)then stat^:=0;
         if(i=sm_listi)then stat^:=1;
         if(i>sm_listi)then stat^:=2;
      end;

      sm_SModel2MWTexture:=@sm_list[mm3i(0,i,sm_listi)];
   end;
end;

function sm_unit2SMAnimState(pu:PTUnit;_wanim_:boolean):byte;  // unit's animation state
begin
   with pu^   do
   with uid^  do
   begin
      if(_wanim_)or(_ukbuilding)
      then sm_unit2SMAnimState:=sms_walk
      else sm_unit2SMAnimState:=sms_stand;

      if(hits          <=0)then begin sm_unit2SMAnimState:=sms_death;exit;end;
      if(not iscomplete   )then begin sm_unit2SMAnimState:=sms_build;exit;end;

      if(not _ukbuilding)then
      begin
      if(buff[ub_Pain  ]>0)then begin sm_unit2SMAnimState:=sms_pain ;exit;end;
      if(buff[ub_Cast  ]>0)then begin sm_unit2SMAnimState:=sms_cast ;exit;end;
      end;

      if(a_reload>0)and(a_weap_cl<=MaxUnitWeapons)then //and(0<a_tar)and(a_tar<=MaxUnits)
       with _a_weap[a_weap_cl] do
        if(aw_max_range>=0)then
        begin
           if not(a_reload in aw_rld_a)
           then sm_unit2SMAnimState:=sms_dready
           else
             if(aw_AnimStay>0)
             then sm_unit2SMAnimState:=aw_AnimStay
             else sm_unit2SMAnimState:=sms_dattack;
        end
        else
           if(a_reload in aw_rld_a)then sm_unit2SMAnimState:=sms_mattack;
   end
end;

function sm_unit2MWTexture(u:PTUnit):PTMWTexture;
var sms:byte;
smodel:PTMWSModel;
begin
   sm_unit2MWTexture:=@spr_dummy;

   with u^   do
   with uid^ do
   begin
      smodel:=un_smodel[level];

      if(smodel<>spr_pdmodel)then
      begin
         sms:=sm_unit2SMAnimState(u,anim_isMoving);

         case sms of
sms_walk:    if(animw>0)then
             begin
                if(anim_isMoving)or(_ukbuilding)then
                begin
                   anim+=animw;
                   if(anim<0)then anim:=0;
                end;
                  sm_unit2MWTexture:=sm_SModel2MWTexture(smodel,sms,dir,anim div 100,nil)
             end
             else sm_unit2MWTexture:=sm_SModel2MWTexture(smodel,sms,dir,0,nil);
sms_dattack,
sms_mattack: if(a_weap<=MaxUnitWeapons)
             then sm_unit2MWTexture:=sm_SModel2MWTexture(smodel,sms,dir,byte(a_reload in _a_weap[a_weap].aw_rld_a),nil)
             else sm_unit2MWTexture:=sm_SModel2MWTexture(smodel,sms,dir,0                                         ,nil);
sms_death:   if(_animd>0)
             then sm_unit2MWTexture:=sm_SModel2MWTexture(smodel,sms,dir,abs(hits) div _animd,nil)
             else sm_unit2MWTexture:=sm_SModel2MWTexture(smodel,sms,dir,0                   ,nil);
sms_build:        sm_unit2MWTexture:=sm_SModel2MWTexture(smodel,sms,dir,(hits*3) div _mhits ,nil);
         else
                  sm_unit2MWTexture:=sm_SModel2MWTexture(smodel,sms,dir,0,nil); //stand,pain,cast
         end;
      end;
   end;
end;

function sm_uid2MWTexture(_uid:byte;dir:integer;level:byte):PTMWTexture;
begin
   with g_uids[_uid] do sm_uid2MWTexture:=sm_SModel2MWTexture(un_smodel[level],sms_stand,dir,0,nil);
end;


