

function _sm2s(sm:PTMWSModel;animk:byte;dir,anim:integer):PTMWSprite;  // sprite model 2 sprite
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
   _sm2s:=@spr_dummy;

   with sm^ do
   begin
      if(sn<=0)then exit;

      if(mkind=smt_fapc)
      then dd:=(abs(dir+12) mod 360) div 23  // 0..15
      else dd:=(abs(dir+23) mod 360) div 45; // 0..7

      if(sk=0)
      then i:=0
      else
      case mkind of
smt_effect  : if(animk=sms_death)
              then i:=anim
              else i:=0;

smt_missile : if(animk=sms_death)
              then i:=8+anim
              else i:=dd;

smt_buiding : case animk of
        sms_build: i:=mm3(0,anim,2);
        sms_death: exit;
              else i:=aa3(3,3+anim,sk);
              end;

smt_turret  : case animk of
        sms_build: i:=mm3(0,anim,2);
        sms_dattack,
        sms_mattack,
        sms_cast : i:=3+dd+(mm3(0,anim,1)*8);
        sms_death: exit;
              else i:=3+dd;
              end;

smt_turret2 : case animk of
        sms_build: i:=mm3(0,anim,2);
        sms_death: exit;
              else i:=3+dd;
              end;

smt_lost    : case animk of
        sms_walk : i:=dd;
        sms_dattack,
        sms_mattack,
        sms_cast : i:=8+dd;
        sms_pain : i:=16+dd;
        sms_death: i:=23+anim;
              else exit;
              end;

smt_imp     : case animk of
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
        sms_walk : i:=4*dd+aa3(0,anim,3);
        sms_death: exit;
              else i:=4*dd;
              end;

smt_zcommando:case animk of
        sms_walk : i:=4*dd+aa3(0,anim,3);
        sms_dattack,
        sms_mattack,
        sms_cast : i:=32+dd+(mm3(0,anim,1)*8);
        sms_pain : i:=48+dd;
        sms_death: i:=56+anim;
              else exit;
              end;

smt_fmajor   :case animk of
        sms_dattack,
        sms_mattack,
        sms_cast : i:=8+dd;
        sms_death: exit;
              else i:=dd;
              end;

smt_caco     :case animk of
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
        sms_walk : i:=dd*6+aa3(0,anim,5);
        sms_dattack,
        sms_mattack,
        sms_cast : i:=48+dd+(mm3(0,anim,1)*8);
        sms_pain : i:=64+dd;
        sms_death: i:=72+anim;
              else exit;
              end;

smt_archno   :case animk of
        sms_walk : i:=dd*6+aa3(0,anim,5);
        sms_dattack,
        sms_mattack,
        sms_cast : i:=48+dd;
        sms_pain : i:=56+dd;
        sms_death: i:=64+anim;
              else exit;
              end;

smt_pain     :case animk of
        sms_walk : i:=dd*2+aa3(0,anim,1);
        sms_dattack,
        sms_mattack,
        sms_cast : if(anim>0)
                   then i:=16+dd
                   else i:=dd*2;
        sms_pain : i:=24+dd;
        sms_death: i:=32+anim;
              else exit;
              end;

smt_revenant :case animk of
        sms_walk : i:=dd*6+aa3(0,anim,5);
        sms_mattack
                 : if(anim>0)
                   then i:=48+dd
                   else i:=dd*6;
        sms_dattack,
        sms_cast : if(anim>0)
                   then i:=56+dd
                   else i:=dd*6;
        sms_pain : i:=64+dd;
        sms_death: i:=72+anim;
              else exit;
              end;

smt_mancubus :case animk of
        sms_walk : i:=dd*6+aa3(0,anim,5);
        sms_mattack,
        sms_dattack,
        sms_cast : i:=48+dd+(mm3(0,anim,1)*8);
        sms_pain : i:=64+dd;
        sms_death: i:=72+anim;
              else exit;
              end;

smt_arch     :case animk of
        sms_walk : i:=dd*6+aa3(0,anim,5);
        sms_mattack,
        sms_dattack
                 : i:=48+dd+mm3(0,anim,1);
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
        sms_pain,
        sms_walk : i:=dd*4+aa3(0,anim,3);
        sms_cast,
        sms_mattack,
        sms_dattack
                 : if(anim>0)
                   then i:=32+dd
                   else i:=dd*4;
        sms_death: i:=40+anim;
              else exit;
              end;

smt_medic    :case animk of
        sms_build: i:=dd;
        sms_pain,
        sms_walk : i:=dd*4+aa3(0,anim,3);
        sms_mattack
                 : if(anim>0)
                   then i:=40+dd
                   else i:=dd*4;
        sms_cast,
        sms_dattack
                 : if(anim>0)
                   then i:=32+dd
                   else i:=dd*4;
        sms_death: i:=48+anim;
              else exit;
              end;

smt_commando :case animk of
        sms_build: i:=dd;
        sms_pain,
        sms_walk : i:=dd*4+aa3(0,anim,3);
        sms_cast,
        sms_mattack,
        sms_dattack
                 : i:=32+dd+(mm3(0,anim,1)*8);
        sms_death: i:=48+anim;
              else exit;
              end;

smt_tank     :case animk of
        sms_build: i:=dd;
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
        sms_pain,
        sms_walk : i:=dd*4+aa3(0,anim,3);
        sms_cast : i:=32+dd;
        sms_mattack,
        sms_dattack
                 : i:=40+dd;
              else exit;
              end;

      else i:=0;
      end;

      _sm2s:=@sl[mm3(0,i,sk)];
   end;

end;

function _unit2SMAnimK(u:PTUnit):byte;
begin
   _unit2SMAnimK:=sms_walk;

   with u^   do
     if(hits          <=0)then _unit2SMAnimK:=sms_death
else if(not bld          )then _unit2SMAnimK:=sms_build
else if(buff[ub_pain  ]>0)then _unit2SMAnimK:=sms_pain
else if(buff[ub_cast  ]>0)
     or(buff[ub_clcast]>0)then _unit2SMAnimK:=sms_cast
else if(a_rld          >0)then _unit2SMAnimK:=sms_dattack; //sms_mattack
end;

function _unit2spr(u:PTUnit):PTMWSprite;
var ak:byte;
smodel:PTMWSModel;
begin
   _unit2spr:=@spr_dummy;

   with u^   do
   with uid^ do
   begin
      smodel:=un_smodel[buff[ub_advanced]>0];

      if(smodel<>spr_pdmodel)then
      begin
         ak:=_unit2SMAnimK(u);

         case ak of
sms_walk:   begin
              if(wanim)or(_isbuilding)then
               begin
                  inc(anim,1);
                  anim:=abs(anim mod 10000);
               end;
               if(_animw>0)
               then _unit2spr:=_sm2s(smodel,ak,dir,anim div _animw)
               else _unit2spr:=_sm2s(smodel,ak,dir,0);
            end;
sms_dattack,
sms_mattack: _unit2spr:=_sm2s(smodel,ak,dir,byte(a_rld>_a_weap[a_weap].aw_rlda));

sms_death:  begin
               anim:=abs(hits);
               if(_animd>0)
               then _unit2spr:=_sm2s(smodel,ak,dir,anim div _animd)
               else _unit2spr:=_sm2s(smodel,ak,dir,0);
            end;
sms_build:  _unit2spr:=_sm2s(smodel,ak,dir,(hits*3) div _mhits);
         else
            _unit2spr:=_sm2s(smodel,ak,dir,0);
         end;
      end;
   end;
end;

function _uid2spr(_uid:byte;adv:boolean):PTMWSprite;
begin
   with _uids[_uid] do
    case _urace of
    r_hell: _uid2spr:=_sm2s(un_smodel[adv],sms_walk,315,0);
    r_uac : _uid2spr:=_sm2s(un_smodel[adv],sms_walk,225,0);
    end;
end;


