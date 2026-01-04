
function SpriteModel2Sprite(sm:PTMWSModel;animk:byte;dir,anim:integer;stat:pbyte):PTMWTexture;  // sprite model 2 sprite
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
   SpriteModel2Sprite:=@spr_dummy;

   if(sm=nil)then exit;

   with sm^ do
   begin
      if(sm_spritesNum<=0)then exit;

      if(sm_kind=smt_fapc)
      then dd:=dir_MOD360(dir+12) div 23  // 0..15
      else dd:=dir_MOD360(dir+23) div 45; // 0..7

      if(sm_spritesLast=0)
      then i:=0
      else
      case sm_kind of
smt_effect  : if(animk=sms_death)
              then i:=anim
              else i:=0;
smt_effect2 : if(animk=sms_death)
              then i:=anim
              else i:=sm_spritesLast;

smt_missile : if(animk=sms_death)
              then i:=8+anim
              else i:=dd;

smt_buiding : case animk of
        sms_build: i:=mm3i(0,anim,2);
        sms_death: exit;
              else i:=aa3(3,3+anim,sm_spritesLast);
              end;

smt_turret  : case animk of
        sms_build: i:=mm3i(0,anim,2);
        sms_dattack,
        sms_mattack,
        sms_cast : i:=11+dd;
        sms_death: exit;
              else i:=3 +dd;
              end;

smt_turret2 : case animk of
        sms_build: i:=mm3i(0,anim,2);
        sms_death: exit;
              else i:=3 +dd;
              end;

smt_lost    : case animk of
        sms_dready,
        sms_stand: i:=dd;
        sms_walk,
        sms_dattack,
        sms_mattack,
        sms_cast : i:=8 +dd;
        sms_pain : i:=16+dd;
        sms_death: i:=23+anim;
              else exit;
              end;

smt_imp     : case animk of
        sms_dready,
        sms_stand,
        sms_walk : i:=4*dd+aa3(0,anim,3);
        sms_dattack,
        sms_mattack,
        sms_cast : if(anim>0)
                   then i:=dd+32
                   else i:=dd*4;
        sms_pain : i:=40+dd;
        sms_death: i:=48+anim;
              else exit;
              end;

smt_zengineer:case animk of
        sms_stand,
        sms_walk : i:=4*dd+aa3(0,anim,3);
        sms_death: i:=32+anim;
              else i:=4*dd;
              end;

smt_zcommando:case animk of
        sms_stand,
        sms_walk : i:=4*dd+aa3(0,anim,3);
        sms_cast,
        sms_mattack,
        sms_dready
                 : i:=32+dd;
        sms_dattack
                 : i:=40+dd;
        sms_pain : i:=48+dd;
        sms_death: i:=56+anim;
              else exit;
              end;

smt_fplasmag :case animk of
        sms_dready,
        sms_dattack,
        sms_mattack,
        sms_cast : i:=8+dd;
        sms_death: exit;
              else i:=dd;
              end;
smt_flyer    :case animk of
        sms_dattack,
        sms_mattack,
        sms_cast : i:=8+dd;
        sms_death: exit;
              else i:=dd;
              end;
smt_caco     :case animk of
        sms_dready,
        sms_stand,
        sms_walk : i:=dd;
        sms_dattack,
        sms_mattack,
        sms_cast : if(anim>0)
                   then i:=8+dd
                   else i:=dd;
        sms_pain : i:=16+dd;
        sms_death: i:=24+anim;
              else exit;
              end;

smt_mmind    :case animk of
        sms_stand,
        sms_walk : i:=dd*6+aa3(0,anim,5);
        sms_dready
                 : i:=48+dd;
        sms_dattack,
        sms_mattack,
        sms_cast : i:=56+dd;
        sms_pain : i:=64+dd;
        sms_death: i:=72+anim;
              else exit;
              end;

smt_archno   :case animk of
        sms_stand,
        sms_walk : i:=dd*6+aa3(0,anim,5);
        sms_dready,
        sms_dattack,
        sms_mattack,
        sms_cast : i:=48+dd;
        sms_pain : i:=56+dd;
        sms_death: i:=64+anim;
              else exit;
              end;

smt_pain     :case animk of
        sms_dready,
        sms_stand,
        sms_walk : i:=dd*2+aa3(0,anim,1);
        sms_dattack,
        sms_mattack,
        sms_cast : i:=16+dd;
        sms_pain : i:=24+dd;
        sms_death: i:=32+anim;
              else exit;
              end;

smt_revenant :case animk of
        sms_dready,
        sms_stand,
        sms_walk : i:=dd*6+aa3(0,anim,5);
        sms_mattack
                 : i:=48+dd;
        sms_dattack,
        sms_cast : i:=56+dd;
        sms_pain : i:=64+dd;
        sms_death: i:=72+anim;
              else exit;
              end;

smt_mancubus :case animk of
        sms_stand,
        sms_walk : i:=dd*6+aa3(0,anim,5);
        sms_dready
                 : i:=48+dd;
        sms_mattack,
        sms_dattack,
        sms_cast : i:=56+dd;
        sms_pain : i:=64+dd;
        sms_death: i:=72+anim;
              else exit;
              end;

smt_arch     :case animk of
        sms_stand,
        sms_walk : i:=dd*6+aa3(0,anim,5);
        sms_dready
                 : i:=48+dd;
        sms_dattack
                 : i:=56+dd;
        sms_mattack,
        sms_cast : i:=64+dd;
        sms_pain : i:=72+dd;
        sms_death: i:=80+anim;
              else exit;
              end;

smt_apc      :case animk of
        sms_death: exit;
              else i:=dd*2+aa3(0,anim,1);
              end;

smt_transport,
smt_fapc     :case animk of
        sms_death: exit;
              else i:=dd;
              end;

smt_marine0  :case animk of
        sms_build: i:=dd;
        sms_dready,
        sms_stand,
        sms_pain,
        sms_walk : i:=dd*4+aa3(0,anim,3);
        sms_cast,
        sms_mattack,
        sms_dattack
                 : i:=32+dd;
        sms_death: i:=40+anim;
              else exit;
              end;

smt_medic    :case animk of
        sms_build: i:=dd;
        sms_dready,
        sms_stand,
        sms_pain,
        sms_walk : i:=dd*4+aa3(0,anim,3);
        sms_mattack
                 : i:=40+dd;
        sms_cast,
        sms_dattack
                 : i:=32+dd;
        sms_death: i:=48+anim;
              else exit;
              end;

smt_commando :case animk of
        sms_build: i:=dd;
        sms_stand,
        sms_pain,
        sms_walk : i:=dd*4+aa3(0,anim,3);
        sms_dready,
        sms_cast,
        sms_mattack
                 : i:=32+dd;
        sms_dattack
                 : i:=40+dd;
        sms_death: i:=48+anim;
              else exit;
              end;

smt_tank     :case animk of
        sms_build: i:=dd;
        sms_dready,
        sms_stand,
        sms_pain,
        sms_walk : i:=dd*2+aa3(0,anim,1);
        sms_cast,
        sms_mattack,
        sms_dattack
                 : if(anim>0)
                   then i:=16+dd
                   else i:=dd*2;
              else exit;
              end;

smt_terminat :case animk of
        sms_build: i:=dd;
        sms_dready,
        sms_stand,
        sms_pain,
        sms_walk : i:=dd*4+aa3(0,anim,3);
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
         if(i<sm_spritesLast)then stat^:=0;
         if(i=sm_spritesLast)then stat^:=1;
         if(i>sm_spritesLast)then stat^:=2;
      end;

      SpriteModel2Sprite:=@sm_spritesL[mm3i(0,i,sm_spritesLast)];
   end;
end;

function unit_GetAnimState(pu:PTUnit;awanim:boolean):byte;  // unit's animation state
begin
   with pu^   do
   with uid^  do
   begin
      if(awanim)or(uid_isbuilding)
      then unit_GetAnimState:=sms_walk
      else unit_GetAnimState:=sms_stand;

      if(hits              <=0)then begin unit_GetAnimState:=sms_death;exit;end;
      if(not iscomplete       )then begin unit_GetAnimState:=sms_build;exit;end;

      if(not uid_isbuilding)then
      begin
      if(buffs[ub_PainState]>0)then begin unit_GetAnimState:=sms_pain ;exit;end;
      if(buffs[ub_Cast     ]>0)then begin unit_GetAnimState:=sms_cast ;exit;end;
      end;

      if(a_rld>0)and(a_weap_cl<=LastUnitArms)then //and(0<a_tar)and(a_tar<=MaxUnits)
        with uid_arms[a_weap_cl] do
          if(aw_max_range>=0)then
          begin
             if not(a_rld in aw_AnimPoints)
             then unit_GetAnimState:=sms_dready
             else
               if(aw_AnimStay>0)
               then unit_GetAnimState:=aw_AnimStay
               else unit_GetAnimState:=sms_dattack;
          end
          else
             if(a_rld in aw_AnimPoints)then unit_GetAnimState:=sms_mattack;
   end
end;

function unit_GetSprite(u:PTUnit):PTMWTexture;
var ak:byte;
smodel:PTMWSModel;
begin
   unit_GetSprite:=@spr_dummy;

   with u^   do
   with uid^ do
   begin
      smodel:=uid_SpriteModel[level];

      if(smodel<>spr_pdmodel)then
      begin
         ak:=unit_GetAnimState(u,wanim);

         case ak of
sms_walk:    if(animw>0)then
             begin
                if(wanim)or(uid_isbuilding)then
                begin
                   anim+=animw;
                   if(buffs[ub_SphereTurbo]>0)then
                     anim+=animw;
                   if(anim<0)then anim:=0;
                end;
                unit_GetSprite:=SpriteModel2Sprite(smodel,ak,dir,anim div 100,nil)
             end
             else unit_GetSprite:=SpriteModel2Sprite(smodel,ak,dir,0,nil);
sms_dattack,
sms_mattack: if(a_weap<=LastUnitArms)
             then unit_GetSprite:=SpriteModel2Sprite(smodel,ak,dir,byte(a_rld in uid_arms[a_weap].aw_AnimPoints),nil)
             else unit_GetSprite:=SpriteModel2Sprite(smodel,ak,dir,0                                            ,nil);
sms_death:   begin
                anim:=abs(hits);
                if(uid_AnimStepDeath>0)
                then unit_GetSprite:=SpriteModel2Sprite(smodel,ak,dir,anim div uid_AnimStepDeath,nil)
                else unit_GetSprite:=SpriteModel2Sprite(smodel,ak,dir,0                         ,nil);
             end;
sms_build:   unit_GetSprite:=SpriteModel2Sprite(smodel,ak,dir,(hits*3) div uid_MaxHits1,nil);
         else
             unit_GetSprite:=SpriteModel2Sprite(smodel,ak,dir,0,nil); //stand,pain,cast
         end;
      end;
   end;
end;

function gfx_uid2spr(auid:byte;dir:integer;level:byte):PTMWTexture;
begin
   with g_uids[auid] do gfx_uid2spr:=SpriteModel2Sprite(uid_SpriteModel[level],sms_stand,dir,0,nil);
end;


