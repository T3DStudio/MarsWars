

procedure unit_death(pu:PTUnit);
var tu  : PTUnit;
    uc  : integer;
begin
   with pu^ do
   with uid^ do
   with player^ do
   if(hits>dead_hits)then
   begin
      if(cycle_order=g_timer_UnitCycle)then
        for uc:=1 to MaxUnits do
          if(uc<>unum)then
          begin
             tu:=g_punits[uc];
             if(tu^.hits>fdead_hits)then unit_detect(pu,tu,point_dist_rint(x,y,tu^.x,tu^.y));
          end;

      if(buff[ub_Resurect]<=0)then
      begin
         if(g_ServerSide)or(hits>fdead_hits)then hits-=1;
         {$IFDEF _FULLGAME}
         if(cycle_order=g_timer_UnitCycle)and(fsr>1)then fsr-=1;
         {$ENDIF}

         if(g_ServerSide)then
           if(hits<=dead_hits)then unit_remove(pu);
      end
      else
        if(g_ServerSide)then
        begin
           if(hits<-fr_fpsd2)then hits:=-fr_fpsd2;
           hits+=1;
           if(hits>=0)then
           begin
              unit_OrderClear(pu,true);
              zfall:=0;
              dir  :=270;
              hits :=_mhits;
              buff[ub_Resurect]:=0;
              buff[ub_Summoned]:=fr_fps1;
              {$IFDEF _FULLGAME}
              unit_CalcFogR(pu);
              effect_UnitSummon(pu,nil);
              {$ENDIF}
           end;
        end;
   end;
end;

procedure unit_damage(pu:PTUnit;damage,pain_f:integer;pl:byte;IgnoreArmor:boolean);
var armor:integer;
begin
   with pu^ do
   if(buff[ub_Invuln]<=0)and(hits>0)then
   with uid^ do
   begin

      armor:=0;

      if(iscomplete)and(not IgnoreArmor)then
      begin
         armor:=_base_armor;
         with player^ do
          if(_ukbuilding)
          then armor+=integer(upgr[_upgr_armor]+upgr[upgr_race_armor_build[_urace]])*BaseArmorBonus2
          else
            if(_ukmech)
            then armor+=integer(upgr[_upgr_armor]+upgr[upgr_race_armor_mech[_urace]])*BaseArmorBonus1
            else armor+=integer(upgr[_upgr_armor]+upgr[upgr_race_armor_bio [_urace]])*BaseArmorBonus1;

         if(level>0)then armor+=level*_level_armor;

         damage-=armor;
      end;

      if(damage<=0)then damage:=1;

      if(hits<=damage)then
      begin
         if(g_ServerSide)
         then unit_kill(pu,false,(hits-damage)<=_fastdeath_hits,true,false,false);
      end
      else
      begin
         buff[ub_Damaged]:=fr_fps2;

         if(g_ServerSide)
         then hits-=damage
         else
           if(buff[ub_Pain]<=0)then exit;

         if(not _ukbuilding)and(not _ukmech)then
          if(pain_f>0)and(_painc>0)then // and(buff[ub_Pain]<=0)
          begin
             if(pain_f>pains)
             then pains:=0
             else pains-=pain_f;

             if(pains=0)then
             begin
                pains:=_painc;

                buff[ub_Pain]:=max2i(pain_time,a_reload);

                with player^ do
                 if(_urace=r_hell)then
                  if(upgr[upgr_hell_pains]>0)then pains+=_painc_upgr_step*upgr[upgr_hell_pains];
                if(level>0)then pains+=level*2;

                {$IFDEF _FULLGAME}
                effect_UnitPain(pu,nil);
                {$ENDIF}
             end;
          end;
      end;
   end;
end;

function unit_morph(pu:PTUnit;ouid:byte;obld:boolean;bhits:integer;ulevel:byte;Check:boolean):cardinal;
var puid: PTUID;
    avsni,
    avsnt: TUnitVisionData;
begin
   unit_morph:=0;
   with pu^     do
   with player^ do
   begin
      if(hits<=0)then
      begin
         unit_morph:=ureq_unknown;
         exit;
      end;

      puid  :=@g_uids[ouid];
      avsni :=TeamDetection;
      avsnt :=TeamVision;

      if(a_units[ouid]<=0)then
      begin
         unit_morph:=ureq_max;
         exit;
      end;
      if(not obld)or(puid^._ukbuilding)then
        if(menergy<=0)then
        begin
           unit_morph:=ureq_energy;
           exit;
        end;
      if(not obld)then
      begin
         if(ukfly)or(transportC>0)then
         begin
            unit_morph:=ureq_unknown;
            exit;
         end;
         if(uid^._isbuilder)and(n_builders<=1)then
         begin
            unit_morph:=ureq_needbuilders;
            exit;
         end;
         if((cenergy-uid^._genergy)<puid^._renergy)or(menergy<=uid^._genergy)then
         begin
            unit_morph:=ureq_energy;
            exit;
         end;
         if(CheckCollisionR(x,y,puid^._r,unum,puid^._ukbuilding,puid^._ukfly,true )<>cbr_no)then
         begin
            unit_morph:=ureq_place;
            exit;
         end;
      end;

      if(Check)then exit;

      vx:=x;
      vy:=y;
      unit_kill(pu,true,true,false,false,true);
      unit_add(x,y,unum,ouid,playeri,obld,true,ulevel);
   end;

   if(bhits<0)then bhits:=puid^._mhits div abs(bhits);
   if(LastCreatedUnitP<>nil)then
     with LastCreatedUnitP^ do
     begin
        TeamDetection:=avsni;
        TeamVision:=avsnt;
        if(bhits>0)then
          if(not iscomplete)then hits:=mm3i(1,bhits,puid^._mhits-1);
     end;
end;

procedure unit_TryMoveToXY(pu:PTUnit;newx,newy:integer);
var cx,cy:integer;
begin
   with pu^ do
     if(ukfly)or(ukfloater)
     then unit_SetXY(pu,newx,newy,mvxy_none,true)
     else
     begin
        cx:=x;
        cy:=y;
        if(map_MapGetZone(cx,newy)=zone)then cy:=newy;
        if(map_MapGetZone(newx,cy)=zone)then cx:=newx;

        if(x<>cx)or(y<>cy)
        then unit_SetXY(pu,cx,cy,mvxy_none,false);
     end;
end;

procedure unit_PushFromUnit(pTarget,pObstacle:PTUnit;uds:single);
var t:single;
   ud:integer;
shortcollision:boolean;
begin
   // pTarget - pushing unit
   // pObstacle - unit-obstacle
   with pTarget^ do
   with uid^ do
   begin
      t :=uds;
      shortcollision:=(pTarget^.player=pObstacle^.player)and((pObstacle^.speed<=0)or(not pObstacle^.iscomplete));
      if(shortcollision)
      then uds-=pObstacle^.uid^._r
      else uds-=pObstacle^.uid^._r+_r;
      ud:=round(uds);

      if(uds<0)then
      begin
         if((pObstacle^.x=x)and(pObstacle^.y=y))then
         begin
            case g_random(4) of
            0: unit_TryMoveToXY(pTarget,x-ud,y   );
            1: unit_TryMoveToXY(pTarget,x+ud,y   );
            2: unit_TryMoveToXY(pTarget,x   ,y-ud);
            3: unit_TryMoveToXY(pTarget,x   ,y+ud);
            end;
         end
         else unit_TryMoveToXY(pTarget,x+round(uds*(pObstacle^.x-x)/t)+g_randomr(2),
                                       y+round(uds*(pObstacle^.y-y)/t)+g_randomr(2));

         vstp+=round(uds/speed*UnitMoveStepTicks);

         if(a_reload<=0)then
           if(vx<>x)or(vy<>y)then
             if(shortcollision)
             then dir:=dir360(dir-(          dir_diff(dir,point_dir(vx,vy,x,y))     div 2 ))
             else dir:=dir360(dir-( mm3i(-90,dir_diff(dir,point_dir(vx,vy,x,y)),90) div 2 ));

         if (pObstacle^.x=pObstacle^.ua_x)
         and(pObstacle^.y=pObstacle^.ua_y)
         and(pObstacle^.ua_id<>ua_patrol )
         and(pObstacle^.ua_id<>ua_apatrol)
         and(not IsIntUnitRange(ua_tar,nil))then
         begin
            ud:=point_dist_rint(ua_x,ua_y,pObstacle^.x,pObstacle^.y)-_r-pObstacle^.uid^._r;
            if(ud<=0)then
            begin
               ua_x:=x;
               ua_y:=y;
            end;
         end;
      end;
   end;
end;

procedure unit_PushOutGrid(pu:PTUnit;debug:boolean=false);
var
cx,cy,
mx,my,
sx,sy,
px,py,
pushr: integer;
begin
   with pu^  do
   with uid^ do
   begin
      sx:=gridx*MapCellW-MapCellW;
      sy:=gridy*MapCellW-MapCellW;
      if(_r>unit_MaxSpeed)
      then pushr:=unit_MaxSpeed
      else pushr:=_r;
      mx:=sx;
      for cx:=-1 to 1 do
      begin
         my:=sy;
         for cy:=-1 to 1 do
         begin
            if(map_CellGetZone(gridx+cx,gridy+cy)<>zone)then
            begin
               //if(isselected)and(debug)then writeln('unit_PushOutGrid ',cx,' ',cy);
               px:=x;
               py:=y;
               mgcell2NearestXY(x,y,mx,my,mx+MapCellW,my+MapCellW,pushr,@px,@py,nil);
               unit_TryMoveToXY(pu,px,py);
            end;

            my+=MapCellW;
         end;
         mx+=MapCellW;
      end;
   end;
end;

function StepCollisionR(sx,sy,sr:integer;azone,adomain1,adomain2:word):boolean;
var
cx0,cy0,
cx1,cy1,
cx ,cy :integer;
begin
   StepCollisionR:=true;
   if(azone=0)then exit;
   cx0:=(sx-sr) div MapCellW;
   cy0:=(sy-sr) div MapCellW;
   cx1:=(sx+sr) div MapCellW;
   cy1:=(sy+sr) div MapCellW;
   for cx:=cx0 to cx1 do
   for cy:=cy0 to cy1 do
     if(cx<0)or(map_csize<cx)
     or(cy<0)or(map_csize<cy)
     then exit
     else
       with map_grid[cx,cy] do
         if(tgc_pf_zone<>azone)
         or((adomain1>0)and(adomain1<>tgc_pf_domain)and((adomain2>0)and(adomain2<>tgc_pf_domain)))    // need (adomain1<>tgc_pf_domain)and(adomain2<>tgc_pf_domain)
         then
           if(dist2mgcellC(sx,sy,cx,cy)<=sr)then exit;
     StepCollisionR:=false;
end;

procedure unit_move(pu:PTUnit);
var
px,py,d,
movePFNext_px,
movePFNext_py,
newx,newy: integer;
rdir     : single;
pf_update: boolean;
movePF_d2: word;
{function StepCollision(cx,cy:integer;azone,adomain1,adomain2:word):boolean;
begin
   StepCollision:=true;
   if(azone=0)then exit;
   cx:=cx div MapCellW;
   cy:=cy div MapCellW;
   if (0<=cx)and(cx<=map_csize)
   and(0<=cy)and(cy<=map_csize)then
     with map_grid[cx,cy] do
     if(tgc_pf_zone=azone)then
     begin
        if(adomain1>0)and(adomain2>0)then
          if (tgc_pf_domain<>adomain1)
          and(tgc_pf_domain<>adomain2)then exit;
        StepCollision:=false;
     end;
end;  }

begin
   with pu^ do
    if(x=vx)and(y=vy)then
     if(x<>moveDest_x)or(y<>moveDest_y)then
      if(not IsIntUnitRange(transport,nil))then
       if(unit_canMove(pu))then
       begin
          pf_update:=false;
          movePFNext_px:=movePFNext_x;
          movePFNext_py:=movePFNext_y;
          if(movePFDest_x<>moveDest_x)or(movePFDest_y<>moveDest_y)then
          begin
             movePFDest_x:=moveDest_x;
             movePFDest_y:=moveDest_y;
             px:=movePFDest_x div MapCellW;
             py:=movePFDest_y div MapCellW;
             if(px<>movePFDest_cx)or(py<>movePFDest_cy)then pf_update:=true;
             movePFDest_cx:=px;
             movePFDest_cy:=py;
          end;
          if(gridx<>movePFPos_cx)or(gridy<>movePFPos_cy)then
          begin
             pf_update:=true;
             movePFPos_cx:=gridx;
             movePFPos_cy:=gridy;
          end;
          if(pf_update)then movePF_direct:=false;

          if(ukfly)or(ukfloater)
          or((movePFDest_cx=movePFPos_cx)and(movePFDest_cy=movePFPos_cy))
          then movePF_direct:=true
          else
            if(pf_update)then
            begin
               movePF_d1:=map_grid[movePFPos_cx ,movePFPos_cy ].tgc_pf_domain;
               movePF_d2:=map_grid[movePFDest_cx,movePFDest_cy].tgc_pf_domain;
               movePF_dx:=movePF_d2;
               movePF_direct:=true;
               if(movePF_d1>0)and(movePF_d2>0)and(movePF_d1<>movePF_d2)then
                 if(not map_GridLineCollision(movePFPos_cx,movePFPos_cy,movePFDest_cx,movePFDest_cy,0))
                 then movePF_direct:=true
                 else
                 begin
                    movePFNext_x:=x;
                    movePFNext_y:=y;
                    movePF_direct:=true;
                    with map_gridDomainMX[movePF_d1-1,movePF_d2-1] do
                    begin
                       movePF_dx:=nextDomain;
                       if(edgeCells_n>0)then
                       begin
                          d:=px.MaxValue;
                          movePF_direct:=false;
                          for px:=0 to edgeCells_n-1 do
                          begin
                             with edgeCells_l[px] do
                               with uid^ do
                                 mgcell2NearestXY(x,y,p_x+_r,p_y+_r,p_x+MapCellW-_r,p_y+MapCellW-_r,0,@newx,@newy,@py);
                             //py:=point_dist_rint(x,y,p_x,p_y);
                             if(py<d)then
                             begin
                                d:=py;
                                movePFNext_x:=newx;
                                movePFNext_y:=newy;
                             end;
                          end;
                       end;
                    end;
                 end;
            end;
          if(movePF_direct)then
          begin
             movePF_d1:=0;
             movePF_dx:=0;
             movePFNext_x:=movePFDest_x;
             movePFNext_y:=movePFDest_y;
          end;

          if(x=movePFNext_x)and(y=movePFNext_y)then exit;

          if(not uid^._slowturn)then
            if(movePFNext_px<>movePFNext_x)
            or(movePFNext_py<>movePFNext_y)
            then dir:=point_dir(x,y,movePFNext_x,movePFNext_y);

          if(speed>unit_MaxSpeed)then speed:=unit_MaxSpeed;

          px:=point_dist_int(x,y,movePFNext_x,movePFNext_y);
          if(px<=speed)then
          begin
             newx:=movePFNext_x;
             newy:=movePFNext_y;
             dir :=point_dir(x,y,newx,newy);
          end
          else
          begin
             dir :=dir_turn(dir,point_dir(x,y,movePFNext_x,movePFNext_y),23);
             rdir:=dir*degtorad;
             newx:=x+round(speed*cos(rdir));
             newy:=y-round(speed*sin(rdir));
          end;

          if(ukfly)or(ukfloater)
          then unit_SetXY(pu,newx,newy,mvxy_none,true)
          else
          with uid^ do
          begin
             px:=x;
             py:=y;
             writeln('1 d1, dx, dir ',movePF_d1,' ',movePF_dx,' ',dir,' direct ',movePF_direct);
             if(not StepCollisionR(newx,y,_r,zone,movePF_d1,movePF_dx))then x:=newx;
             if(not StepCollisionR(x,newy,_r,zone,movePF_d1,movePF_dx))then y:=newy;
             if(x<>newx)or(y<>newy)then
               if(x=px)and(y=py)then
               begin
                  dir+=90+(180*g_random(2));
                  writeln('dir ',dir);
               end
               else
               begin
                  writeln('2 d1, dx, ',movePF_d1,' ',movePF_dx);
                  newx:=px+(sign(x-px)*speed);
                  newy:=py+(sign(y-py)*speed);
                  if(not StepCollisionR(newx,y,_r,zone,movePF_d1,movePF_dx))then x:=newx;
                  if(not StepCollisionR(x,newy,_r,zone,movePF_d1,movePF_dx))then y:=newy;
                  dir:=point_dir(px,py,x,y);
               end;
             unit_UpdateXY(pu,true);
          end;
       end;
   {if(isselected)then writeln('step 1 ',movePF_d1,' ',movePF_dx,' dir ',dir);
   if(isselected)then writeln('x y ',x,' ',y);
   px:=x;
   py:=y;
   if(not StepCollision(newx,y,zone,movePF_d1,movePF_dx))then x:=newx;
   if(not StepCollision(x,newy,zone,movePF_d1,movePF_dx))then y:=newy;
   if(isselected)then writeln('x y ',x,' ',y);
   if(isselected)then writeln('push out 1');
   unit_PushOutGrid(pu,true);
   if(isselected)then writeln('x y ',x,' ',y);
   if(x=px)and(y=py)then
   begin
      dir+=180+g_randomr(90);
      if(isselected)then writeln('dir turn 180 ',dir);
   end
   else
     if(x=newx)and(y=newy)
     then begin if(isselected)then writeln('step ok ',movePF_d1,' ',movePF_dx) end
     else
     begin
        if(isselected)then writeln('step 2 ',movePF_d1,' ',movePF_dx);
        newx:=px+(sign(x-px)*speed);
        newy:=py+(sign(y-py)*speed);
        if(not StepCollision(newx,y,zone,movePF_d1,movePF_dx))then x:=newx;
        if(not StepCollision(x,newy,zone,movePF_d1,movePF_dx))then y:=newy;
        if(isselected)then writeln('x y ',x,' ',y);
        if(isselected)then writeln('push out 2');
        unit_PushOutGrid(pu,true);
        if(isselected)then writeln('x y ',x,' ',y);
        if(x<>px)or(y<>py)
        then dir:=point_dir(px,py,x,y);
        {if(x=px)and(y=py)then
        begin
           dir+=90+g_random(180);
           if(isselected)then writeln('dir turn 2 ',dir);
        end
        else
        begin
           dir:=point_dir(px,py,x,y);
           if(isselected)then writeln('point_dir  ',dir);
        end;}
     end;  }
end;

function target_weapon_check(pAttacker,pTarget:PTUnit;target_dist:integer;uWeaponN:byte;CheckVision,noSRangeCheck:boolean):byte;
var awr   :integer;
transportu:PTUnit;
pfcheck,
canmove   :boolean;
begin
   target_weapon_check:=wmove_impassible;

   //pAttacker - attacker
   //pTarget   - target

   if(CheckVision)then
     if(not CheckUnitTeamVision(pAttacker^.player^.team,pTarget,false))then exit;
   if(uWeaponN>MaxUnitWeapons)then exit;
   if(pTarget^.hits<=fdead_hits)then exit;
   if(target_dist<0)
   or(target_dist=NOTSET)then target_dist:=point_dist_int(pAttacker^.x,pAttacker^.y,pTarget^.x,pTarget^.y);

   with pAttacker^ do
   with uid^ do
   with player^ do
   with _a_weap[uWeaponN] do
   begin
      if(aw_reload=0)then exit;

      // Weapon type requirements
      case aw_type of
wpt_resurect : if(pTarget^.buff[ub_Resurect     ]>0)
               or(pTarget^.buff[ub_PauseResurect]>0)
               or(pTarget^.hits<=fdead_hits        )
               or(pTarget^.hits> 0                 )then exit;
wpt_heal     : if(pTarget^.hits<=0)
               or(pTarget^.hits>=pTarget^.uid^._mhits)
               or(not pTarget^.iscomplete            )
               or(pTarget^.buff[ub_Heal]>0           )then exit;
      end;

      // Transport check
      transportu:=nil;
      if(pTarget<>pAttacker)then
        if(IsIntUnitRange(transport,@transportu))then
        begin
           if(IsIntUnitRange(pTarget^.transport,nil))then
           begin
              if(transportu<>pTarget)and(transport<>pTarget^.transport)then exit;
              if(aw_max_range>=0)then exit; // only melee attack
           end
           else
             if(transportu<>pTarget)
             then exit
             else
               if(aw_max_range>=0)then exit; // ranged
        end
        else
          if(IsIntUnitRange(pTarget^.transport,nil))then exit;

      // UID and UPID requirements
      if(aw_ruid >0)and(uid_eb[aw_ruid ]<=0         )then exit;
      if(aw_rupgr>0)and(upgr  [aw_rupgr]< aw_rupgr_l)then exit;

      // requirements to attacker and some flags

      if not(pTarget^.uidi in aw_uids)then exit;

      if((aw_reqf and wpr_air   )>0)then
       if(ukfly=uf_ground)or(pTarget^.ukfly=uf_ground)then exit;
      if((aw_reqf and wpr_ground)>0)then
       if(ukfly=uf_fly   )or(pTarget^.ukfly=uf_fly   )then exit;
      if((aw_reqf and wpr_reload)>0)then
       if(reload>0)then exit;

      if(aw_type=wpt_directdmgZ)then
      begin
         if(not pTarget^.iscomplete)
         or(pTarget^.uid^._zombie_uid =0)
         or(pTarget^.uid^._zombie_hits<pTarget^.hits)
         or(pTarget^.hits<=fdead_hits   )then exit;
      end;

      // requirements to target

      if((aw_tarf and wtr_owner_p  )=0)and(pTarget^.playeri      =playeri       )then exit;
      if((aw_tarf and wtr_owner_a  )=0)and(pTarget^.player^.team =team          )then exit;
      if((aw_tarf and wtr_owner_e  )=0)and(pTarget^.player^.team<>team          )then exit;

      if((aw_tarf and wtr_hits_h   )=0)and((0<pTarget^.hits)
                                       and(pTarget^.hits< pTarget^.uid^._mhits ))then exit;
      if((aw_tarf and wtr_hits_d   )=0)and(pTarget^.hits<=0                     )then exit;
      if((aw_tarf and wtr_hits_a   )=0)and(pTarget^.hits =pTarget^.uid^._mhits  )then exit;

      if((aw_tarf and wtr_complete )=0)and(    pTarget^.iscomplete              )then exit;
      if((aw_tarf and wtr_ncomplete)=0)and(not pTarget^.iscomplete              )then exit;

      if(not pTarget^.uid^._ukbuilding  )then
      begin
      if((aw_tarf and wtr_stun     )=0)and(pTarget^.buff[ub_Pain]> 0       )then exit;
      if((aw_tarf and wtr_nostun   )=0)and(pTarget^.buff[ub_Pain]<=0       )then exit;
      end;

      if(not CheckUnitBaseFlags(pTarget,aw_tarf))then exit;

      // Distance requirements
      if(aw_max_range=aw_srange) // = srange
      then awr:=target_dist-srange
      else
        if(aw_max_range<aw_srange) // melee
        then awr:=target_dist-(_r+pTarget^.uid^._r-aw_max_range)  // need transport check
        else
          if(aw_max_range>=aw_fsr0)  // relative srange
          then awr:=target_dist-(srange+(aw_max_range-aw_fsr))
          else awr:=target_dist-aw_max_range; // absolute
      if(aw_max_range>=aw_srange)then
      begin
         if(pTarget^.ukfly)
         then awr-=_a_BonusRangeAntiFly
         else awr-=_a_BonusRangeAntiGround;
         if(pTarget^.uid^._ukbuilding)
         then awr-=_a_BonusRangeAntiBuilding
         else awr-=_a_BonusRangeAntiUnit;
      end;

      canmove:=(speed>0)and(ua_id<>ua_stay)and(transportu=nil);
      // pfzone check for melee
      pfcheck:=(ukfly)or(ukfloater)or(zone=pTarget^.zone);

      if(awr<0)then
      begin
         if(target_dist>=aw_min_range)
         then target_weapon_check:=wmove_noneed     // can attack now
         else
           if(canmove)
           then target_weapon_check:=wmove_farther  // need move farther
           else ;                                   // target too close & cant move
      end
      else
        if(canmove)and(pfcheck)then
         if(target_dist<=(srange+TargetCheckSRangeBonus))or(noSRangeCheck)
         then target_weapon_check:=wmove_closer     // need move closer
         else ;                                     // target too far & cant move
   end;
end;

function unit_target2weapon(pAttacker,pTarget:PTUnit;ud:integer;cw:byte;action:pbyte):byte;
var i,a:byte;
begin
   unit_target2weapon:=255;

   // pAttacker - attacker
   // pTarget - target

   if(not CheckUnitTeamVision(pAttacker^.player^.team,pTarget,false))then exit;
   if(pTarget^.hits<=fdead_hits)or(pTarget^.buff[ub_Invuln]>0)then exit;
   if(ud<0)then ud:=point_dist_int(pAttacker^.x,pAttacker^.y,pTarget^.x,pTarget^.y);
   if(cw>MaxUnitWeapons)then cw:=MaxUnitWeapons;
   if(action<>nil)then action^:=0;

   for i:=0 to cw do
   begin
      a:=target_weapon_check(pAttacker,pTarget,ud,i,false,action<>nil);
      if(a=wmove_impassible)then continue;
      if(action<>nil)then action^:=a;
      unit_target2weapon:=i;
      break;
   end;
end;

function _unitWeaponPriority(tu:PTUnit;priorset:byte;highprio:boolean):integer;
var i:integer;
procedure incPrio(add:boolean);
begin
   if(add)
   then _unitWeaponPriority+=i;
   i:=i div 2;
end;
begin
   i:=4096;
   _unitWeaponPriority:=0;

   incPrio(tu^.buff[ub_Invuln]<=0);
   incPrio(highprio);

   with tu^  do
   with uid^ do
   case priorset of
wtp_building         : incPrio(    _ukbuilding   );
wtp_BuildingHeavy    : begin
                       incPrio(    _ukbuilding   );
                       incPrio(not _uklight      );
                       incPrio(not iscomplete    );
                       end;
wtp_UnitLightBio     : begin
                       incPrio(not _ukbuilding   );
                       incPrio(    _uklight      );
                       incPrio(not _ukmech       );
                       incPrio(not iscomplete    );
                       end;
wtp_UnitBioLight     : begin
                       incPrio(not _ukbuilding   );
                       incPrio(not _ukmech       );
                       incPrio(    _uklight      );
                       incPrio(not iscomplete    );
                       end;
wtp_UnitBioHeavy     : begin
                       incPrio(not _ukbuilding   );
                       incPrio(not _ukmech       );
                       incPrio(not _uklight      );
                       incPrio(not iscomplete    );
                       end;
wtp_UnitMech         : begin
                       incPrio(not _ukbuilding   );
                       incPrio(    _ukmech       );
                       incPrio(not iscomplete    );
                       end;
wtp_UnitBio          : begin
                       incPrio(not _ukbuilding   );
                       incPrio(not _ukmech       );
                       incPrio(not iscomplete    );
                       end;
wtp_Bio              : begin
                       incPrio(not _ukmech       );
                       incPrio(not iscomplete    );
                       end;
wtp_Light            : incPrio(    _uklight      );
wtp_Fly              : begin
                       incPrio(     ukfly        );
                       incPrio(uidi<>UID_LostSoul);
                       incPrio(not iscomplete    );
                       end;
wtp_nolost_hits      : incPrio(uidi<>UID_LostSoul);
wtp_UnitLight       : begin
                       incPrio(not _ukbuilding   );
                       incPrio(    _uklight      );
                       incPrio(not iscomplete    );
                       end;
wtp_limit            : incPrio(not _ukbuilding   );
wtp_limitaround      : _unitWeaponPriority+=tu^.aiu_limitaround_ally div ul1;
wtp_Scout            : begin
                       incPrio(_limituse<ul3);
                       incPrio(ukfly or ukfloater);
                       incPrio(transportM<=0);
                       _unitWeaponPriority+=speed;
                       end;
   end;
end;

function unit_PickTarget(pu,tu:PTUnit;ud:integer;a_tard:pinteger;t_weap:pbyte;a_tarp:PPTUnit;t_prio:pinteger):boolean;
var tw:byte;
n_prio:integer;
begin
   unit_PickTarget:=false;
   with pu^ do
   with uid^ do
   begin
      tw:=unit_target2weapon(pu,tu,ud,t_weap^,nil);

      if(tw>MaxUnitWeapons)then exit;

      unit_PickTarget:=true;

      if(tw>t_weap^)
      then exit
      else
       with _a_weap[tw] do
        if(tw<t_weap^)
        then n_prio:=_unitWeaponPriority(tu,aw_tarprior,ai_HighPriorityTarget(player,tu))
        else
        begin
           n_prio:=_unitWeaponPriority(tu,aw_tarprior,ai_HighPriorityTarget(player,tu));

           case aw_tarprior of
           wtp_notme_hits: if(tu<>pu)then n_prio+=1;
           wtp_limit     : n_prio+=tu^.uid^._limituse;
           end;

           //if(n_prio>t_prio^)then ;
           if(n_prio=t_prio^)then
           case aw_tarprior of
wtp_max_hits          : if(tu^.hits       <a_tarp^^.hits       )
                        then exit
                        else
                          if(tu^.hits     =a_tarp^^.hits       )then
                            if(ud         >a_tard^             )then exit;
wtp_distance          : if(ud             >a_tard^             )then exit;
wtp_nolost_hits,
wtp_hits              : if(tu^.hits       >a_tarp^^.hits       )
                        then exit
                        else
                          if(tu^.hits     =a_tarp^^.hits       )then
                            if(ud         >a_tard^             )then exit;

wtp_Rmhits            : if(tu^.uid^._mhits<a_tarp^^.uid^._mhits)
                        then exit
                        else
                          if(tu^.uid^._mhits=a_tarp^^.uid^._mhits)then
                            if(ud           >a_tard^             )then exit;
           else
              if(aw_max_range<0)and(aw_type=wpt_directdmg)
              then begin if(ud  >a_tard^             )then exit; end
              else
                if(tu^.hits     >a_tarp^^.hits       )
                then exit
                else
                  if(tu^.hits   =a_tarp^^.hits       )then
                    if(ud       >a_tard^             )then exit;
           end;
           if(n_prio<t_prio^)then exit;
        end;

      t_prio^:=n_prio;
      t_weap^:=tw;
      a_tar  :=tu^.unum;
      a_tard^:=ud;
      a_tarp^:=tu;
   end;
end;

procedure unit_aura_effects(pu,tu:PTUnit;ud:integer);
begin
   // pu - aura source
   // tu - target
   with pu^     do
   with uid^    do
   with player^ do
   case uidi of
UID_HKeep     : if(ud<srange)
               and(not tu^.uid^._ukbuilding)
               and(team<>tu^.player^.team)then
                 if(tu^.buff[ub_Decay]<=fr_fpsd2)and(upgr[upgr_hell_paina]>0)then
                 begin
                    unit_damage(tu,DecayAuraDamage,1,playeri,true);
                    tu^.buff[ub_Decay]:=fr_fps1;
                 end;
   end;
end;

procedure unit_capture_point(pu:PTUnit);
var i :byte;
begin
   with pu^ do
    for i:=1 to LastKeyPoint do
     with g_KeyPoints[i] do
      if(kp_CaptureR>0)then
       if(point_dist_int(x,y,kp_x,kp_y)<=kp_CaptureR)then
       begin
          kp_PlayerUnits[playeri     ]+=uid^._limituse;
          kp_TeamUnits  [player^.team]+=uid^._limituse;
       end;
end;

procedure unit_mcycle(pu:PTUnit);
var uc,
t_prio,
a_tard,
nup_tar,
uontard,
    ud : integer;
    uds: single;
a_tarp,
pup_tar,
tu_transport,
    tu : PTUnit;
good_target,
swtarget,
aicode,
fteleport_tar,
attack_target,
pushout: boolean;
t_weap : byte;
begin
   with pu^     do
   with uid^    do
   with player^ do
   begin
      a_tar   := 0;
      a_tard  := NOTSET;
      a_tarp  := nil;
      t_weap  := 255;
      t_prio  := 0;
      nup_tar  := 0;
      uontard := NOTSET;
      tu_transport:=nil;
      if(WaitForNextTarget>0)
      then WaitForNextTarget-=1;

      u_royal_cd:=NOTSET;
      u_royal_d :=NOTSET;
      if(map_scenario=ms_royale)then
      begin
         u_royal_cd:=point_dist_int(x,y,map_phsize,map_phsize);
         u_royal_d :=g_RoyalBattle_r-u_royal_cd;
         if(u_royal_d<_missile_r)then
         begin
            unit_kill(pu,false,false,true,true,false);
            exit;
         end;
      end;

      if(_ukbuilding)and(menergy<=0)then
      begin
         unit_kill(pu,false,false,true,false,true);
         exit;
      end;

      pushout      := solid and unit_canMove(pu) and (a_reload<=0);
      attack_target:= unit_canAttack(pu,false);
      aicode       := (player_type=pt_ai);//and(isselected);
      fteleport_tar:= (not IsIntUnitRange(ua_tar,nil))and(_ability=ua_HTeleport);
      swtarget     := false;
      pup_tar:=nil;
      if(IsIntUnitRange(ua_tar,@pup_tar))and(aicode=false)then
        if(pup_tar^.player=player)and(pup_tar^.hits>0)and(pup_tar^.reload>0)then
          case g_uids[pup_tar^.uidi]._ability of
ua_HTeleport     : swtarget:=true;
          end;

      aiu_InitVars(pu);
      if(aicode)then
      begin
         ai_InitVars(pu);
         ai_CollectData(pu,pu,0,nil,false);
      end;
      aiu_CollectData(pu,pu,0,nil,false);

      if(attack_target)then unit_PickTarget(pu,pu,0,@a_tard,@t_weap,@a_tarp,@t_prio);

      for uc:=1 to MaxUnits do
      if(uc<>unum)then
      begin
         tu:=g_punits[uc];

         if(tu^.hits>fdead_hits)then
         begin
            uds:=point_dist_real(x,y,tu^.x,tu^.y);
            ud :=round(uds);

            tu_transport:=nil;
            IsIntUnitRange(tu^.transport,@tu_transport);

            if(tu_transport=nil)then unit_detect(pu,tu,ud);

            if(attack_target)
            then good_target:=unit_PickTarget(pu,tu,ud,@a_tard,@t_weap,@a_tarp,@t_prio)
            else good_target:=false;

            aiu_CollectData(pu,tu,ud,tu_transport,good_target);
            if(aicode)then ai_CollectData(pu,tu,ud,tu_transport,good_target);

            if(tu^.hits>0)and(tu_transport=nil)then
            begin
               unit_aura_effects(pu,tu,ud);

               if(pushout)then
                 if(_r<=tu^.uid^._r)or(tu^.speed<=0)or(not tu^.iscomplete)then
                   if(tu^.solid)and(ukfly=tu^.ukfly)then unit_PushFromUnit(pu,tu,uds);

               if(swtarget)then
                 if(ud<srange)and(tu^.playeri=playeri)and(tu^.uidi=pup_tar^.uidi)and(tu^.reload<pup_tar^.reload)then
                   if(IsIntUnitRange(tu^.ua_tar,nil)and(tu^.ua_tar=pup_tar^.ua_tar))
                   or((tu^.ua_x=pup_tar^.ua_x)and(tu^.ua_y=pup_tar^.ua_y))
                   then ua_tar:=tu^.unum;

               if(fteleport_tar)then
               begin
                  ud:=point_dist_int(ua_x,ua_y,tu^.x,tu^.y)-tu^.uid^._r;
                  if(ud<srange)and(ud<uontard)then
                   if(team=tu^.player^.team)then
                   begin
                      nup_tar:=uc;
                      uontard:=ud;
                   end;
               end;
            end;
         end;
      end;

      //unit_PushFromObstacles(pu);
      if(not ukfly)and(not ukfloater)
      then unit_PushOutGrid(pu);


      if(fteleport_tar)and(nup_tar>0)then ua_tar:=nup_tar;

      if(attack_target)and(a_tard<NOTSET)then WaitForNextTarget:=0;

      //aiu_code(pu);
      //if(aicode){and(playeri=PlayerClient)}then ai_code(pu);

      if(buff[ub_Damaged]>0)then GameLogUnitAttacked(pu);
   end;
end;

procedure unit_mcycle_cl(pu,transportu:PTUnit);
var uc,a_tard,
t_prio,
    ud : integer;
a_tarp,
    tu : PTUnit;
t_weap : byte;
udetect,
attack_target: boolean;
begin
   with pu^ do
   with uid^ do
   with player^ do
   begin
      WaitForNextTarget:=0;
      if(g_ServerSide)then
      begin
         a_tar  :=0;
         a_tard :=NOTSET;
         t_weap :=255;
         a_tarp :=nil;
         t_prio :=0;
         attack_target:=unit_canAttack(pu,false);
      end
      else attack_target:=false;

      if(transportu<>nil)then
      begin
         if(IsIntUnitRange(transportu^.transport,nil))then exit;
         TeamVision   :=transportu^.TeamVision;
         udetect:=false;
      end
      else udetect:=true;

      if(not udetect)and(not attack_target)then exit;  // in transport & client side

      if(attack_target)and(g_ServerSide)then unit_PickTarget(pu,pu,0,@a_tard,@t_weap,@a_tarp,@t_prio);

      for uc:=1 to MaxUnits do
      if(uc<>unum)then
      begin
         tu:=g_punits[uc];
         if(tu^.hits>fdead_hits)then
         begin
            ud:=point_dist_rint(x,y,tu^.x,tu^.y);

            if(udetect)then
            begin
               unit_detect(pu,tu,ud);
               if(transportu=nil)and(tu^.hits>0)then
                if(not IsIntUnitRange(tu^.transport,nil))then unit_aura_effects(pu,tu,ud);
            end;
            if(attack_target)then unit_PickTarget(pu,tu,ud,@a_tard,@t_weap,@a_tarp,@t_prio);
         end;
      end;
   end;
end;

function unit_TransportLoad(pTransport,pTarget:PTUnit):boolean;
begin
   //pTransport - transport
   //pTarget    - target
   unit_TransportLoad:=false;
   if(unit_TransportCheck(pTransport,pTarget))then
     with pTransport^ do
     begin
        transportC+=pTarget^.uid^._transportS;
        pTarget^.transport:=unum;
        pTarget^.a_tar:=0;
        if(ua_tar=pTarget^.unum)then          ua_tar:=0;
        if(pTarget^.ua_tar=unum)then pTarget^.ua_tar:=0;
        unit_UnSelect(pTarget);
        {$IFDEF _FULLGAME}
        SoundPlayUnit(snd_transport,pTransport,nil);
        {$ENDIF}
        unit_TransportLoad:=true;
     end;
end;
function unit_TransportUnload(pTransport,pTarget:PTUnit):boolean;
begin
   //pTransport - transport
   //pTarget - target inside
   unit_TransportUnload:=false;
   if(pTransport=nil)then
     if(not IsIntUnitRange(pTarget^.transport,@pTransport))then exit;
   with pTarget^ do
     if(transport=pTransport^.unum)and(pTransport^.buff[ub_PauseUnload]<=0)then
     begin
        pTransport^.buff[ub_PauseUnload]:=fr_fpsd4;
        pTransport^.transportC-=uid^._transportS;
        transport:=0;
        unit_SetXY(pTarget,pTransport^.x,
                           pTransport^.y,mvxy_strict,false);
        unit_OrderClear(pTarget,true);
        {$IFDEF _FULLGAME}
        SoundPlayUnit(snd_transport,pTransport,nil);
        {$ENDIF}
        unit_TransportUnload:=true;
     end;
   //with pTransport^ do
   // if(transportC<=0)then ua_id:=ua_amove;
end;

procedure unit_InTransportCode(pTarget,pTransport:PTUnit);
var tu:PTUnit;
begin
   // pTarget - unit inside
   // pTransport - transport
   with pTarget^ do
   begin
      x    :=pTransport^.x;
      y    :=pTransport^.y;
      gridx:=pTransport^.gridx;
      gridy:=pTransport^.gridy;
      zone :=pTransport^.zone;
      {$IFDEF _FULLGAME}
      fx   :=pTransport^.fx;
      fy   :=pTransport^.fy;
      mmx  :=pTransport^.mmx;
      mmy  :=pTransport^.mmy;
      {$ENDIF}

      if(g_ServerSide)then
      begin
         //if(pTransport^.ua_id=ua_unload)or(pTransport^.transportC>pTransport^.transportM)then
         //  if(not map_IsObstacleZone(pTransport^.zone))then
         //    if(unit_TransportUnload(pTransport,pTarget))then exit;

         if(pTransport^.ua_id=ua_move   )
         or(pTransport^.ua_id=ua_stay   )
         or(pTransport^.ua_id=ua_amove  )
         or(pTransport^.ua_id=ua_patrol )
         or(pTransport^.ua_id=ua_apatrol)then ua_id:=pTransport^.ua_id;

         if(IsIntUnitRange(pTransport^.ua_tar,@tu))then
         begin
            a_tar:=pTransport^.ua_tar;
            if(unit_target2weapon(pTarget,tu,-1,255,nil)<=MaxUnitWeapons)then ua_id:=ua_amove;
         end;
      end;
   end;
end;

{function unit_rebuild(pu:PTUnit;Check:boolean):boolean;
begin
   unit_rebuild:=false;
   with pu^ do
    with uid^ do
     if(not PlayerSetProdError(playeri,lmt_argt_unit,uidi,unit_canRebuild(pu),pu))then
      unit_rebuild:=not PlayerSetProdError(playeri,lmt_argt_unit,uidi,unit_morph(pu,_rebuild_uid,false,g_uids[_rebuild_uid]._hhmhits,_rebuild_level,Check),pu);
end; }

{function unit_sability(pu:PTUnit;Check:boolean):boolean;
begin
   unit_sability:=false;
   with pu^ do
   with uid^ do
     if(transportC>0)then
     begin
        unit_sability:=true;
        if(not Check)then ua_id:=ua_unload;
     end
     else
       if(not PlayerSetProdError(playeri,lmt_argt_unit,uidi,unit_canAbility(pu),pu))then
         with player^ do
           case _ability of
uab_SpawnLost     : if(buff[ub_Cast]<=0)and(buff[ub_CCast]<=0)then
                    begin
                       unit_sability:=true;
                       if(not Check)then
                       begin
                          buff[ub_Cast ]:=fr_fpsd2;
                          buff[ub_CCast]:=fr_fps2;
                          if(upgr[upgr_hell_phantoms]>0)
                          then ability_SpawnUnitStep(pu,UID_Phantom )
                          else ability_SpawnUnitStep(pu,UID_LostSoul);
                       end;
                    end;
uab_CCFly         : if(zfall=0)and(buff[ub_CCast]<=0)then
                    begin
                       unit_sability:=true;
                       if(not Check)then
                         {if(level>0)
                         then level:=0
                         else level:=1};
                    end;
uab_RebuildInPoint: unit_sability:=unit_rebuild(pu,Check);
           else
              PlayerSetProdError(playeri,lmt_argt_unit,uidi,ureq_usepsaorder,pu);
           end;
end; }
{function unit_psability(pu:PTUnit;o_x,o_y,o_tar:integer;Check:boolean):boolean;
begin
   unit_psability:=false;
   with pu^ do
   with uid^ do
     if(transportC>0)then
     begin
        unit_psability:=true;
        if(not Check)then unit_SetOrder(pu,0,o_x,o_y,-1,-1,ua_psability,true );
     end
     else
       if(not PlayerSetProdError(playeri,lmt_argt_unit,uidi,unit_canAbility(pu),pu))then
         with uid^ do
         begin
            case _ability of
uab_UACStrike        : unit_psability:=unit_ability_UACStrike (pu,o_x,o_y     ,Check);
uab_UACScan          : unit_psability:=unit_ability_UACScan   (pu,o_x,o_y     ,Check);
uab_HInvulnerability : unit_psability:=unit_ability_HellInvuln(pu,o_tar       ,Check);
uab_HTowerBlink      : unit_psability:=unit_ability_HellSBlink(pu,o_x,o_y     ,Check);
uab_HKeepBlink       : unit_psability:=unit_ability_HellLBlink(pu,o_x,o_y     ,Check);
uab_HellVision       : unit_psability:=unit_ability_HellVision(pu,o_tar       ,Check);
uab_Teleport         : unit_psability:=unit_ability_HellRecall(pu,o_tar,NOTSET,Check);
uab_RebuildInPoint   : if(speed>0)then
                       begin
                          unit_psability:=true;
                          if(not Check)then
                          begin
                             //not ukfloater or(player^.upgr[upgr_race_extbuilding[uid^._urace]]<=0)
                             pushOut_all(o_x,o_y,g_uids[_rebuild_uid]._r,unum,@o_x,@o_y,false);
                             unit_SetOrder(pu,0,o_x,o_y,-1,-1,ua_psability,false);
                          end;
                       end;
uab_CCFly            : if(speed>0)then
                       begin
                          unit_psability:=true;
                          if(not Check)then
                          begin
                             //player^.upgr[upgr_race_extbuilding[uid^._urace]]<=0
                             pushOut_all(o_x,o_y,_r,unum,@o_x,@o_y,false );
                             unit_SetOrder(pu,0,o_x,o_y-fly_hz,-1,-1,ua_psability,false);
                          end;
                       end
                       else
                         if(unit_sability(pu,Check))then
                           if(Check)
                           then unit_psability:=true
                           else
                           begin
                              // player^.upgr[upgr_race_extbuilding[uid^._urace]]<=0
                              pushOut_all(o_x,o_y,_r,unum,@o_x,@o_y,false );
                              unit_SetOrder(pu,0,o_x,o_y-fly_hz,-1,-1,ua_psability,false);
                              unit_psability:=true;
                           end;

            end;
         end;
end;  }

procedure unit_StartResurrection(tu:PTUnit);
begin
   with tu^ do
   begin
      buff[ub_Resurect]:=fr_fps2;
      zfall:=-uid^._zfall;
      ukfly:= uid^._ukfly;
   end;
end;

function unit_TryZombification(pu,tu:PTUnit):boolean;
var _h:single;
    _l,
    _o:byte;
    _f:boolean;
    _d,
    _z:integer;
 _zuid:PTUID;
    {$IFDEF _FULLGAME}
    _s:integer;
    {$ENDIF}
begin
   unit_TryZombification:=false;

   //pu - zombificator
   //tu - target

   if(tu^.uid^._zombie_uid=0)then exit;
   _zuid:=@g_uids[tu^.uid^._zombie_uid];

   with pu^ do
   with uid^ do
   with player^ do
   begin
      if((armylimit-_limituse+_zuid^._limituse)>MaxPlayerLimit)then exit;
      if((menergy-_genergy+_zuid^._genergy)<=0)then exit;
   end;

   if(tu^.iscomplete=false)
   or(tu^.uid^._zombie_uid =0)
   or(tu^.uid^._zombie_hits<tu^.hits)
   or(tu^.hits<=fdead_hits          )then exit;

   if(g_ServerSide)then
   begin
      _h:=tu^.hits/tu^.uid^._mhits;
      _d:=tu^.dir;
      _o:=pu^.group;
      _f:=tu^.ukfly;
      _z:=tu^.zfall;
      _l:=tu^.level;
      {$IFDEF _FULLGAME}
      _s:=tu^.shadow;
      {$ENDIF}

      unit_kill(pu,true,true,false,false,true);
      unit_add(tu^.x,tu^.y,pu^.unum,tu^.uid^._zombie_uid,pu^.playeri,true,true,_l);
      unit_kill(tu,true,true,false,false,true);

      if(LastCreatedUnit>0)then
      with LastCreatedUnitP^ do
      begin
         group:=_o;
         dir  :=_d;
         ukfly:=_f;
         hits := trunc(uid^._mhits*_h);
         zfall:=_z;
         {$IFDEF _FULLGAME}
         shadow:=_s;
         {$ENDIF}
         if(hits<=0)then
         begin
            unit_PC_base_dec(LastCreatedUnitP);
            unit_StartResurrection(LastCreatedUnitP);
         end;
      end;
   end;
   unit_TryZombification:=true;
end;

procedure unit_AddExp(pu:PTUnit;exp:cardinal);
begin
   with pu^ do
   if(level<MaxUnitLevel)then
   with uid^ do
   begin
      a_exp+=exp;
      if(a_exp>=a_exp_next)then
      begin
         level+=1;
         a_exp:=0;
         a_exp_next:=level*ExpLevel1+ExpLevel1;
         GameLogUnitPromoted(pu);
         {$IFDEF _FULLGAME}
         effect_LevelUp(pu,0,nil);
         {$ENDIF}
      end;
   end;
end;

function unit_attack(pAttacker:PTUnit):boolean;
var w,a   : byte;
pTarget   : PTUnit;
damage,
upgradd,c : integer;
fakemissile,
AttackInMove: boolean;
{$IFDEF _FULLGAME}
attackervis,
targetvis : boolean;
{$ENDIF}
procedure AttackEffects;
var i:byte;
begin
   with pAttacker^ do
   with uid^ do
   with _a_weap[a_weap] do
   begin
      if((aw_reqf and wpr_avis)>0)then
      begin
         AddToInt(@pTarget^.TeamVision[player^.team],MinVisionTime);
         {$IFDEF _FULLGAME}
         if not(a_reload in aw_rld_a)then
           if(AddToInt(@pTarget^.buff[ub_ArchFire],fr_fps1))then SoundPlayUnit(snd_archvile_fire,pTarget,@targetvis);
         {$ENDIF}
      end;
      AddToInt(@TeamVision[pTarget^.player^.team],a_reload+1);
      AddToInt(@TeamVision[pTarget^.player^.team],MinVisionTime);
      for i:=0 to LastPlayer do
        if(pTarget^.TeamVision[i]>0)
        or(    TeamVision[i]>0)then
        begin
                TeamVision[i]:=max2i(TeamVision[i],pTarget^.TeamVision[i]);
            pTarget^.TeamVision[i]:=TeamVision[i];
        end;
   end;
end;
begin
   unit_attack:=false;
   with pAttacker^ do
   if(IsIntUnitRange(a_tar,@pTarget))then
   begin
      if(g_ServerSide)then
      begin
         if(a_reload<=0)then
         begin
            w:=unit_target2weapon(pAttacker,pTarget,-1,255,@a);

            if(w>MaxUnitWeapons)or(a=wmove_impassible)then
            begin
               if(g_ServerSide)then
               begin
                  a_tar:=0;
                  WaitForNextTarget:=1;
               end;
               exit;
            end;

            a_weap:=w;
         end
         else
         begin
            a:=target_weapon_check(pAttacker,pTarget,-1,a_weap,true,false);

            if(a=0)then
            begin
               if(g_ServerSide)then
               begin
                  a_tar:=0;
                  WaitForNextTarget:=1;
               end;
               exit;
            end;
         end;

         unit_attack:=true;

         upgradd:=0;

         with uid^ do
          with _a_weap[a_weap] do
           AttackInMove:=(aw_reqf and wpr_move)>0;

         case a of
wmove_closer    : begin
                     if(not AttackInMove)then
                     begin
                        moveDest_x:=pTarget^.x;
                        moveDest_y:=pTarget^.y;
                     end;
                     exit;
                  end;
wmove_farther   : begin
                     if(not AttackInMove)or(ua_bx<=0)then  // not patroling
                       if(x=pTarget^.x)and(y=pTarget^.y)then
                       begin
                          moveDest_x:=x-g_randomr(2);
                          moveDest_y:=y-g_randomr(2);
                       end
                       else
                       begin
                          moveDest_x:=x-(pTarget^.x-x);
                          moveDest_y:=y-(pTarget^.y-y);
                       end;
                     exit;
                  end;
wmove_noneed    : if(not AttackInMove)then
                  begin
                     moveDest_x:=x;
                     moveDest_y:=y;
                  end;
         else
           WaitForNextTarget:=1;
           exit;
         end;
      end
      else
      begin
         unit_attack:=true;
         if(a_weap>MaxUnitWeapons)then exit;

         if(pTarget^.hits<=fdead_hits)then exit;

         with uid^ do
          with _a_weap[a_weap] do
           AttackInMove:=(aw_reqf and wpr_move)>0;
      end;

      if(not unit_canAttack(pAttacker,true))then
      begin
         moveDest_x:=x;
         moveDest_y:=y;
         exit;
      end;

      // attack code
      with uid^ do
      with _a_weap[a_weap] do
      begin
         {$IFDEF _FULLGAME}
         targetvis  :=ui_CheckUnitUIPlayerVision(pTarget,true);
         attackervis:=ui_CheckUnitUIPlayerVision(pAttacker,true);
         {$ENDIF}

         if(a_reload<=0)then
         begin
            a_shots  +=1;
            a_reload :=aw_reload;
            a_tar_cl :=a_tar;
            a_weap_cl:=a_weap;

            if(g_ServerSide)and(not _ukbuilding)then
              if((aw_max_range<0)and(aw_type=wpt_directdmg))
              then unit_AddExp(pAttacker,aw_reload*2)
              else unit_AddExp(pAttacker,aw_reload  );
            if(not AttackInMove)then
            begin
               if(x<>pTarget^.x)
               or(y<>pTarget^.y)then dir:=point_dir(x,y,pTarget^.x,pTarget^.y);
               if(g_ServerSide)then WaitForNextTarget:=(a_reload div order_period)+1;
            end;
            {$IFDEF _FULLGAME}
            effect_UnitAttack(pAttacker,true,@attackervis);
            {$ENDIF}
            AttackEffects;
         end;

         if(cycle_order=g_timer_UnitCycle)then AttackEffects;

         {$IFDEF _FULLGAME}
         if(targetvis)then
          if(aw_eid_target>0)and(aw_eid_target_onlyshot=false)then
          begin
             if(not IsIntUnitRange(pTarget^.transport,nil))then
              if((G_Step mod fr_fpsd3)=0)then effect_add(pTarget^.vx,pTarget^.vy,SpriteDepth(pTarget^.vy+1,pTarget^.ukfly),aw_eid_target);
             if(aw_snd_target<>nil)then
              if((G_Step mod fr_fps1)=0)then SoundPlayUnit(aw_snd_target,pTarget,@targetvis);
          end;
         {$ENDIF}

         if(a_reload in aw_rld_s)then
         begin
            if(aw_fakeshots=0)
            then fakemissile:=false
            else fakemissile:=(a_shots mod aw_fakeshots)>0;
            {$IFDEF _FULLGAME}
            effect_UnitAttack(pAttacker,false,@attackervis);
            if(targetvis)then
             if(aw_eid_target>0)and(aw_eid_target_onlyshot)then
             begin
                if(not IsIntUnitRange(pTarget^.transport,nil))then
                effect_add(pTarget^.vx-g_randomr(pTarget^.uid^._missile_r),pTarget^.vy-g_randomr(pTarget^.uid^._missile_r),SpriteDepth(pTarget^.vy+1,pTarget^.ukfly),aw_eid_target);

                SoundPlayUnit(aw_snd_target,pTarget,@targetvis);
             end;
            {$ENDIF}
            if(aw_dupgr>0)and(aw_dupgr_s>0)then upgradd:=player^.upgr[aw_dupgr]*aw_dupgr_s;
            if(level>0)and(not _ukbuilding)then upgradd+=level*_level_damage;
            if(not AttackInMove)then
              if(x<>pTarget^.x)
              or(y<>pTarget^.y)then dir:=point_dir(x,y,pTarget^.x,pTarget^.y);
            case aw_type of
wpt_missle     : if(aw_oid>0)then
                  if(aw_count=0)
                  then missile_add(pTarget^.x,pTarget^.y,vx+aw_x,vy+aw_y,a_tar,aw_oid,playeri,ukfly,pTarget^.ukfly,fakemissile,upgradd,aw_dmod)
                  else
                    if(aw_count>0)
                    then for c:=1 to aw_count do missile_add(pTarget^.x,pTarget^.y,vx+aw_x,vy+aw_y,a_tar,aw_oid,playeri,ukfly,pTarget^.ukfly,fakemissile,upgradd,aw_dmod)
                    else
                      if(aw_count<0)then
                      begin
                         missile_add(pTarget^.x,pTarget^.y,vx-aw_count+aw_x,vy-aw_count+aw_y,a_tar,aw_oid,playeri,ukfly,pTarget^.ukfly,fakemissile,upgradd,aw_dmod);
                         missile_add(pTarget^.x,pTarget^.y,vx+aw_count+aw_x,vy+aw_count+aw_y,a_tar,aw_oid,playeri,ukfly,pTarget^.ukfly,fakemissile,upgradd,aw_dmod);
                      end;
wpt_unit       : if(not fakemissile)then ability_SpawnUnitStep(pAttacker,aw_oid);
wpt_directdmg  : if(not fakemissile)and(aw_count>0)then
                   unit_damage(pTarget,ApplyDamageMod(pTarget,aw_dmod,aw_count+upgradd),1,playeri,false);
wpt_directdmgZ : if(not fakemissile)then
                   if(not unit_TryZombification(pAttacker,pTarget))then
                     unit_damage(pTarget,ApplyDamageMod(pTarget,aw_dmod,aw_count+upgradd),1,playeri,false);
wpt_suicide    : if(g_ServerSide)then unit_kill(pAttacker,false,true,true,false,true);
            else
              if(g_ServerSide)and(not fakemissile)then
              case aw_type of
wpt_resurect   : begin
                    unit_StartResurrection(pTarget);
                    if((aw_reqf and wpr_reload)>0)then reload:=max2i(0,aw_count*fr_fps1);
                 end;
wpt_heal       : begin
                    pTarget^.hits:=mm3i(1,pTarget^.hits+aw_count+upgradd,pTarget^.uid^._mhits);
                    pTarget^.buff[ub_Heal]:=aw_reload;
                 end;
              end;
            end;
         end;
      end;
   end;
end;

procedure unit_uaTar(pu:PTUnit);
var
puatar : PTUnit;
td,tdm : integer;
a,w    : byte;
begin
   with pu^  do
   with uid^ do
   if(ua_tar=unum)
   then ua_tar:=0
   else
     if(IsIntUnitRange(ua_tar,@puatar))then
     begin
        if(IsIntUnitRange(puatar^.transport,nil))
        or(not CheckUnitTeamVision(player^.team,puatar,false))then
        begin
           ua_tar:=0;
           exit;
        end;

        td :=point_dist_int(x,y,puatar^.x,puatar^.y);
        if(puatar^.solid)
        then tdm:=td-     (_r+puatar^.uid^._r)
        else tdm:=td-min2i(_r,puatar^.uid^._r);

        if(tdm<melee_r)then
        begin
           if(unit_TransportLoad(pu,puatar))then exit;
           if(unit_TransportLoad(puatar,pu))then exit;
        end;

        case _ability of
ua_HTeleport    : if(puatar^.player^.team<>player^.team)then begin ua_tar:=0;exit; end;
        end;

        case puatar^.uid^._ability of
ua_HTeleport    : if(ability_teleport(pu,puatar,td))then exit;//team
        end;

        w:=unit_target2weapon(pu,puatar,td,255,@a);
        if(w<=MaxUnitWeapons)then
        begin
           a_tar :=ua_tar;
           ua_id :=ua_amove;
        end;

        if(tdm<=melee_r)then
        begin
           ua_x:=x;
           ua_y:=y;
           exit;
        end;

        if(player=puatar^.player)and(puatar^.ukfly)then
          if(unit_TransportCheck(puatar,pu))and(not IsIntUnitRange(puatar^.ua_tar,nil))and(puatar^.ua_x=puatar^.x)and(puatar^.ua_y=puatar^.y)then
          begin
             puatar^.ua_x:=x;
             puatar^.ua_y:=y;
          end;

        ua_x:=puatar^.vx;
        ua_y:=puatar^.vy;
     end;
end;

function unit_Action(pu:PTUnit):boolean;
begin
   unit_Action:=false;
   with pu^     do
   with uid^    do
   with player^ do
   begin
      if(ua_id=0)then ua_id:=ua_amove;

      if(speed<=0)then
        case ua_id of
        ua_astay,
        ua_stay,
        ua_apatrol,
        ua_patrol,
        ua_move,
        ua_unloadto: ua_id:=ua_amove;
        ua_amove   :;
        ua_destroy :;
        else
            //if(ua_id<>_ability)then ua_id:=ua_astay;
        end;

      case ua_id of
  ua_amove,
  ua_move    : begin
                  unit_uaTar(pu);
                  unit_Action:=(x=ua_x)and(y=ua_y);
                  moveDest_x :=ua_x;
                  moveDest_y :=ua_y;
               end;
  ua_apatrol,
  ua_patrol  : begin
                  if(x=ua_x)and(y=ua_y)then
                  begin
                     ua_tar:=0;
                     ua_x  :=ua_bx;
                     ua_y  :=ua_by;
                     ua_bx :=x;
                     ua_by :=y;
                  end;
                  moveDest_x:=ua_x;
                  moveDest_y:=ua_y;
               end;
  ua_astay,
  ua_stay    : begin
                  ua_tar:=0;
                  ua_bx :=-1;
                  ua_x  :=x;
                  ua_y  :=y;
                  moveDest_x:=ua_x;
                  moveDest_y:=ua_y;
               end;
  ua_unload  : begin
                  unit_Action:=(transportC<=0);
                  ua_x:=x;
                  ua_y:=y;
                  moveDest_x:=ua_x;
                  moveDest_y:=ua_y;
               end;
  ua_unloadto: begin
                  if(x=ua_x)and(y=ua_y)
                  then ua_id:=ua_unload;
                  moveDest_x:=ua_x;
                  moveDest_y:=ua_y;
               end;
  ua_destroy : unit_kill(pu,false,false,true,true,true);
  ua_Upgrade : ;
      else

      end;
   end;
   {
   ua_amove               = 0;
   ua_apatrol             = 1;
   ua_move                = 2;
   ua_patrol              = 3;
   ua_stay                = 4;
   ua_unload              = 5;
   ua_ability1            = 6;
   ua_ability2            = 7;
   ua_ability3            = 8;
   ua_destroy             = 9;
   }
end;

procedure unit_NextOrder(pu:PTUnit);
begin

end;

procedure unit_BaseBehavior(pu,pTransport:PTUnit);
begin
   if(pTransport<>nil)then unit_InTransportCode(pu,pTransport);

   with pu^ do
   if(g_ServerSide)then
   begin
      if(pTransport=nil)then
        if(unit_Action(pu))then
          unit_NextOrder(pu);

      if(hits>0)then
        if(ua_id=ua_amove  )
        or(ua_id=ua_apatrol)
        or(ua_id=ua_astay  )then
        begin
           unit_attack(pu);
           if(WaitForNextTarget>0)then
           begin
              moveDest_x:=x;
              moveDest_y:=y;
           end;
        end
        else WaitForNextTarget:=0;
   end
   else
   begin
      unit_attack(pu);

      if(pTransport=nil)and(cycle_order=g_timer_UnitCycle)then
        if(movePFDest_x<>x)or(movePFDest_y<>y)then
        begin
           movePFDest_x:=x;
           movePFDest_y:=y;
        end;
   end;
end;

procedure unit_regeneration(pu:PTUnit);
var i:integer;
begin
   with pu^     do
   with uid^    do
   with player^ do
   if(buff[ub_Damaged]<=0)and(hits<_mhits)then
   begin
      i:=upgr[_upgr_regen];
      if(_ukbuilding)
      then i+=upgr[upgr_race_regen_build[_urace]]
      else
        if(_ukmech)
        then i+=upgr[upgr_race_regen_mech[_urace]]
        else i+=upgr[upgr_race_regen_bio [_urace]];
      i:=(i*BaseArmorBonus1)+_baseregen;

      if(i>0)then
      begin
         hits+=i;
         if(hits>_mhits)then hits:=_mhits;
      end;
   end;
end;

procedure unit_build(pu:PTUnit);
begin
   with pu^     do
   with uid^    do
   with player^ do
   if(cenergy>=0)then
   begin
      if(g_timer_UnitCycle=cycle_order)and(buff[ub_Damaged]<=0)then
      begin
         hits+=_bstep;
         hits+=_bstep*upgr[upgr_fast_build];
      end;

      if(hits>=_mhits){$IFDEF _FULLGAME}or(test_fastprod){$ENDIF}then
      begin
         hits:=_mhits;
         iscomplete :=true;
         unit_PC_complete_inc(pu);
         cenergy+=_renergy;
         GameLogUnitReady(pu);
      end;
   end;
end;

procedure unit_prod(pu:PTUnit);
procedure uXCheck(pui:pinteger);
begin
   if(not IsIntUnitRange(pui^,nil))then pui^:=pu^.unum;
end;
begin
   with pu^     do
   with uid^    do
   with player^ do
   begin
      unit_ProdUnitEnd(pu);
      unit_ProdUpgrEnd(pu);

      uXCheck(@uid_x[            uidi]);
      uXCheck(@ucl_x[_ukbuilding,_ucl]);
   end;
end;

procedure UnitsCode;
var
u         : integer;
pu,
transportu: PTUnit;
begin
   for u:=1 to MaxUnits do
   begin
      transportu:=nil;
      pu:=g_punits[u];
      with pu^ do
      if(hits>dead_hits)then
      begin
         if(cycle_order=g_timer_UnitCycle)then
         unit_BaseVision(pu,false);

         unit_BaseCounters(pu);

         if(hits>0)then
         begin
            IsIntUnitRange(transport,@transportu);

            if(cycle_order=g_timer_UnitCycle)then
            unit_Bonuses(pu);

            unit_BaseBehavior(pu,transportu);

            if(hits<=0)then continue;

            if(g_ServerSide)and(iscomplete)then
            begin
               unit_move(pu);

               if(cycle_order=g_timer_UnitRegen)then
               unit_regeneration(pu);

               unit_prod(pu);
            end
            else unit_build(pu);

            {if(cycle_order=g_timer_UnitCycle)then
              if(g_ServerSide)and(transportu=nil)
              then unit_mcycle   (pu)
              else unit_mcycle_cl(pu,transportu);

            if(g_ServerSide)and(transportu=nil)then
              unit_capture_point(pu);   }
         end
         else unit_death(pu);

         unit_MoveSprite(pu);
      end;
   end;
end;

////////////////////////////////////////////////////////////////////////////////




