{$IFDEF _FULLGAME}
procedure unit_UpdateMiniMapXY(pu:PTUnit);
begin
   with pu^ do
   begin
      mmx:=trunc(x*map_mm_cx);
      mmy:=trunc(y*map_mm_cx);
   end;
end;

procedure effect_LevelUp(pu:PTUnit;etype:byte;vischeck:pboolean);
begin
   with pu^ do
   begin
      if(vischeck<>nil)then
      begin
         if(not vischeck^)then exit
      end
      else
         if(not ui_CheckUnitUIPlayerVision(pu,false))then exit;

      case etype of
EID_HVision : begin
              SoundPlayUnit(snd_hell_eye,pu,nil);
              effect_add(vx,vy,SpriteDepth(vy+1,ukfly),etype);
              end;
EID_Invuln  : begin
              SoundPlayUnit(snd_hell_invuln,pu,nil);
              effect_add(vx,vy,SpriteDepth(vy+1,ukfly),etype);
              end;
      else
         case uid^._urace of
r_hell : begin
            SoundPlayUnit(snd_unit_adv[uid^._urace],pu,nil);
            effect_add(vx,vy,SpriteDepth(vy+1,ukfly),EID_HLevelUp);
         end;
r_uac  : begin
            SoundPlayUnit(snd_unit_adv[uid^._urace],pu,nil);
            effect_add(vx,vy,SpriteDepth(vy+1,ukfly),EID_ULevelUp);
         end;
         end;
      end;
   end;
end;

procedure effect_UACStrikeShot(pu:PTUnit);
begin
   with pu^ do
   begin
      effect_add(vx,vy-15,SpriteDepth(vy+10,ukfly),EID_Exp2);
      SoundPlayUnit(snd_bomblaunch,nil,nil)
   end;
end;

procedure effect_CPExplode(vx,vy:integer);
begin
   effect_add(vx,vy,sd_liquid+vy,EID_db_u0);
   if(ui_MapPointInRevealedInScreen(vx,vy))then
   begin
      effect_add(vx,vy,SpriteDepth(vy+1,false),EID_BBExp);
      SoundPlayUnit(snd_exp,nil,nil);
   end;
end;

procedure effect_UnitSummon(pu:PTUnit;vischeck:pboolean);
begin
   with pu^ do
   if(hits>0)and(iscomplete)then
   with uid^ do
   begin
      if(vischeck<>nil)then
      begin
         if(not vischeck^)then exit
      end
      else
         if(not ui_CheckUnitUIPlayerVision(pu,true))then exit;

      SoundPlayUnit(un_eid_snd_summon,nil,nil);
      effect_add(vx,vy,SpriteDepth(vy+1,ukfly),un_eid_summon[level]);

      if(playeri=UIPlayer)then SoundPlayUnit(un_snd_ready,nil,nil);
   end;
end;

procedure effect_UnitDeath(pu:PTUnit;fastdeath:boolean;vischeck:pboolean);
begin
   with pu^ do
   with uid^ do
   begin
      if(not ukfly)then
      effect_add(vx,vy+un_eid_bcrater_y,sd_liquid+vy,un_eid_bcrater);

      if(vischeck<>nil)then
      begin
         if(not vischeck^)then exit
      end
      else
        if(not ui_CheckUnitUIPlayerVision(pu,true))then exit;

      if(fastdeath)then
      begin
         effect_add(vx,vy,SpriteDepth(vy+1,ukfly),un_eid_fdeath[level]);
         SoundPlayUnit(un_eid_snd_fdeath,nil,nil);
      end
      else
      begin
         effect_add(vx,vy,vy+1,un_eid_death[level]);
         SoundPlayUnit(un_eid_snd_death,nil,nil);
      end;
   end;
end;

procedure effect_UnitPain(pu:PTUnit;vischeck:pboolean);
begin
   with pu^ do
   with uid^ do
   begin
      if(vischeck<>nil)then
      begin
         if(not vischeck^)then exit
      end
      else
        if(not ui_CheckUnitUIPlayerVision(pu,true))then exit;

      effect_add(vx,vy,SpriteDepth(vy+1,ukfly),un_eid_pain[level]);
      SoundPlayUnit(un_eid_snd_pain,nil,nil);
   end;
end;

procedure effect_Common(tx,ty,dy:integer;vischeck:pboolean;effect:byte;sound:PTSoundSet);
begin
   if(vischeck<>nil)then
   begin
      if(not vischeck^)then exit
   end
   else
     if(not ui_MapPointInRevealedInScreen(tx,ty))then exit;

   effect_add(tx,ty,dy,effect);
   SoundPlayUnit(sound,nil,nil);
end;

procedure effect_UnitAttack(pu:PTUnit;start:boolean;vischeck:pboolean);
begin
   with pu^  do
   with uid^ do
   with _a_weap[a_weap] do
   begin
      if(vischeck<>nil)then
      begin
         if(not vischeck^)then exit
      end
      else
        if(not ui_CheckUnitUIPlayerVision(pu,true))then exit;

      if(start)then
      begin
         effect_add(vx,vy,SpriteDepth(vy+1,ukfly),aw_eid_start);
         SoundPlayUnit(aw_snd_start,nil,nil);
      end
      else
      begin
         effect_add(vx+aw_x,vy+aw_y,SpriteDepth(vy+1,ukfly),aw_eid_shot );
         SoundPlayUnit(aw_snd_shot,nil,nil);
      end;
   end;
end;

{$ENDIF}

procedure pushOut_GridUAction(apx,apy:pinteger;r:integer;azone:word);
var
gr,gx,gy,
cx,cy,
rd,rx,ry,
i,u,outc:integer;
procedure AddResult(x,y:integer);
var mx,my,d:integer;
begin
   if(map_CellGetZone(x,y)<>azone)then exit;
   mx:=x*MapCellW+MapCellhW;
   my:=y*MapCellW+MapCellhW;
   d:=abs(cx-mx)+abs(cy-my);
   if(d<rd)then
   begin
      rx:=x;
      ry:=y;
      rd:=d;
   end;
end;
begin
   cx:=apx^;
   cy:=apy^;
   gx:=cx div MapCellW;
   gy:=cy div MapCellW;
   rd:=NOTSET;
   gr:=0;
   while(rd=NOTSET)do
   begin
      if(gr=0)then
      begin
         if(map_CellGetZone(gx,gy)=azone)then
         begin
            rx:=gx;
            ry:=gy;
            rd:=0;
            break;
         end;
      end
      else
      begin
         outc:=0;

         u:=gy-gr;if(map_InGridRange(u))then begin outc+=1;for i:=max2i(gx-gr  ,0) to min2i(gx+gr  ,map_LastCell) do AddResult(i,u);end;
         u:=gy+gr;if(map_InGridRange(u))then begin outc+=1;for i:=max2i(gx-gr  ,0) to min2i(gx+gr  ,map_LastCell) do AddResult(i,u);end;
         u:=gx-gr;if(map_InGridRange(u))then begin outc+=1;for i:=max2i(gy-gr+1,0) to min2i(gy+gr-1,map_LastCell) do AddResult(u,i);end;
         u:=gx+gr;if(map_InGridRange(u))then begin outc+=1;for i:=max2i(gy-gr+1,0) to min2i(gy+gr-1,map_LastCell) do AddResult(u,i);end;

         if(outc=0)then break;
      end;
      gr+=1;
   end;

   if(rd<NOTSET)then
   begin
      gx:=rx*MapCellW;
      gy:=ry*MapCellW;
      mgcell2NearestXY(cx,cy,gx+r,gy+r,gx+MapCellW-r,gy+MapCellW-r,0,@rx,@ry,nil);
      apx^:=rx;
      apy^:=ry;
   end;
end;

procedure unit_SetOrder(pu:PTUnit;otarget,ox,oy,obx,oby:integer;oid:byte;tryPushOut:boolean);
begin
   with pu^ do
   begin
      if(tryPushOut)then
        if(not ukfly)and(not ukfloater)then pushOut_GridUAction(@ox,@oy,uid^._r+1,zone);
      ua_bx :=obx;
      ua_by :=oby;
      ua_x  :=ox;
      ua_y  :=oy;
      ua_tar:=otarget;
      ua_id :=oid;
   end;
end;

function unit_UA2UO(pu:PTUnit):byte;
begin
   with pu^ do
     if(ua_bx>=0)then
     begin
        if(ua_id=ua_attack)
        then unit_UA2UO:=uo_apatrol
        else unit_UA2UO:=uo_patrol;
     end
     else
       case ua_id of
       ua_move     : if(ua_x=x)and(ua_y=y)
                     then unit_UA2UO:=uo_stay
                     else unit_UA2UO:=uo_move;
       ua_hold     : unit_UA2UO:=uo_hold;
       ua_unload   : unit_UA2UO:=uo_unload;
       ua_psability: unit_UA2UO:=uo_psability;
       else
           if(ua_x=x)and(ua_y=y)
           then unit_UA2UO:=uo_stay
           else unit_UA2UO:=uo_attack;
       end;
end;
procedure unit_ClientUO2UA(pu:PTUnit;uo_order:byte);
begin
   with pu^ do
     case uo_order of
     uo_move     : unit_SetOrder(pu,0,x,y,-1,-1,ua_move     ,false);
     uo_stay,
     uo_attack   : unit_SetOrder(pu,0,x,y,-1,-1,ua_attack   ,false);
     uo_hold     : unit_SetOrder(pu,0,x,y,-1,-1,ua_hold     ,false);
     uo_psability: unit_SetOrder(pu,0,x,y,-1,-1,ua_psability,false);
     uo_unload   : unit_SetOrder(pu,0,x,y,-1,-1,ua_unload   ,false);
     uo_patrol   : unit_SetOrder(pu,0,x,y, x, y,ua_move     ,false);
     uo_apatrol  : unit_SetOrder(pu,0,x,y, x, y,ua_attack   ,false);
     else          unit_SetOrder(pu,0,x,y,-1,-1,ua_attack   ,false);
     end;
end;

function unit_canMove(pu:PTUnit):boolean;
begin
   with pu^ do
   with uid^ do
    if(not ServerSide)and(speed>0)
    then unit_canMove:=(x<>moveCurr_x)or(y<>moveCurr_y)
    else
    begin
       unit_canMove:=false;

       if(speed<=0)
       or(hits<=0)
       or(not iscomplete)then exit;

       if(a_reload>0)then
        if(a_weap_cl>MaxUnitWeapons)
        then exit
        else
         with _a_weap[a_weap_cl] do
          if((aw_reqf and wpr_move)=0)then exit;

       if(not _ukbuilding)then
         if(buff[ub_Pain]>0)
         or(buff[ub_Cast]>0)then exit;

       unit_canMove:=true;
    end;
end;

function unit_canAttack(pu:PTUnit;check_buffs:boolean):boolean;
var tu:PTUnit;
begin
   unit_canAttack:=false;
   with pu^  do
   with uid^ do
   begin
      if(not iscomplete)
      or(hits<=0)
      or(_attack=atm_none)then exit;

      if(check_buffs)then
        if(not _ukbuilding)then
          if(buff[ub_Pain]>0)
          or(buff[ub_Cast]>0)then exit;

      case _attack of
   atm_bunker,
   atm_always  : if(IsUnitRange(transport,@tu))then
                 begin
                    if(IsUnitRange(tu^.transport,nil))then exit;
                    case tu^.uid^._attack of
                    atm_always,
                    atm_none,
                    atm_sturret: exit;
                    end;
                 end;
   atm_sturret : if(transportC<=0)then exit;
   atm_intransport   : if(not IsUnitRange(transport,nil))then exit;
      else exit;
      end;
   end;
   unit_canAttack:=true;
end;

procedure unit_UpdateXY(pu:PTUnit;updateZone:boolean);
begin
   with pu^ do
   begin
      gridx:=x div MapCellW;
      gridy:=y div MapCellW;
      if(updateZone)then zone:=map_CellGetZone(gridx,gridy);

      {$IFDEF _FULLGAME}
      unit_UpdateMiniMapXY(pu);
      unit_UpdateFogXY(pu);
      {$ENDIF}
   end;
end;

procedure unit_SetXY(pu:PTUnit;newx,newy:integer;movevxy:byte;updateZone:boolean); //;
var _px,_py:integer;
begin
   with pu^ do
   begin
      _px:=x;
      _py:=y;
      x:=mm3i(1,newx,map_size);
      y:=mm3i(1,newy,map_size);
      if(x<>_px)or(y<>_py)then
      begin
         unit_UpdateXY(pu,updateZone);
         if(_px=ua_x)
        and(_py=ua_y)then
        begin
           ua_x:=x;
           ua_y:=y;
        end;
      end;
      case movevxy of
mvxy_relative: begin
                  vx+=x-_px;
                  vy+=y-_py;
               end;
mvxy_strict  : begin
                  vx:=x;
                  vy:=y;
               end;
      end;
   end;
end;

procedure unit_BaseVision(pu:PTUnit;reset:boolean);
var t:byte;
begin
   with pu^ do
   with player^ do
   begin
      if(reset)then
      begin
         FillChar(TeamVision   ,SizeOf(TeamVision   ),0);
         FillChar(TeamDetection,SizeOf(TeamDetection),0);
      end;
      AddToInt(@TeamVision   [team],MinVisionTime);
      AddToInt(@TeamDetection[team],MinVisionTime);

      if(isrevealed)then
        for t:=0 to MaxPlayers do
        begin
           AddToInt(@TeamVision   [t],fr_fps1);
           AddToInt(@TeamDetection[t],fr_fps1);
        end;
   end;
end;
procedure unit_UpVision(pu:PTUnit);
var p:byte;
begin
   with pu^ do
    for p:=0 to MaxPlayers do
    begin
       if(TeamVision   [p]>0)then AddToInt(@TeamVision   [p],MinVisionTime);
       if(TeamDetection[p]>0)then AddToInt(@TeamDetection[p],MinVisionTime);
    end;
end;

procedure unit_OrderClear(pu:PTUnit;clearid:boolean);
begin
   with pu^ do
   begin
      if(clearid)
      then ua_id:=ua_attack;

      ua_tar:=0;
      ua_x  :=x;
      ua_y  :=y;
      ua_bx :=-1;
   end;
end;
procedure units_TargetClear(utar:integer);
var u:integer;
begin
   for u:=1 to MaxUnits do
     with g_punits[u]^ do
       if(ua_tar=utar)then ua_tar:=0;
end;
procedure missiles_TargetClear(u:integer;ResetTargetXY:boolean);
var i:integer;
begin
   for i:=1 to MaxUnits do
    with g_missiles[i] do
     if(vstep>0)and(tar=u)then
     begin
        tar:=0;
        if(ResetTargetXY)then
        begin
           x:=vx;
           y:=vy;
           vstep:=1;
        end;
     end;
end;

procedure teleport_SetReloadTimer(pTeleporter:PTUnit;limit:longint);
begin
   // pTeleporter - teleporter
   with pTeleporter^ do
    with player^ do reload:=integer(round(fr_fps1*limit/MinUnitLimit))*(teleport_SecPerLimit-mm3i(0,upgr[upgr_hell_teleport],teleport_SecPerLimit));
end;

procedure unit_teleport(pTarget:PTUnit;tx,ty:integer{$IFDEF _FULLGAME};eidstart,eidend:byte;snd:PTSoundSet{$ENDIF});
begin
   with pTarget^ do
   begin
      tx:=mm3i(0,tx,map_size);
      ty:=mm3i(0,ty,map_size);
      {$IFDEF _FULLGAME}
      effect_teleport(vx,vy,tx,ty,ukfly,eidstart,eidend,snd);
      {$ENDIF}
      buff[ub_Teleport]:=fr_fps1;
      unit_SetXY(pTarget,tx,ty,mvxy_strict,true);
      unit_OrderClear(pTarget,false);
      units_TargetClear(unum);
      missiles_TargetClear(unum,false);
      unit_UpVision(pTarget);
   end;
end;

procedure unit_zfall(pu:PTUnit);
var st:integer;
begin
   with pu^ do
   if(zfall<>0)then
   begin
      st:=sign(zfall);
      if(zfall>1)then st*=2;
      zfall-=st;
      unit_SetXY(pu,x,y+st,mvxy_relative,false);
   end;
end;

procedure unit_MoveSprite(pu:PTUnit);
begin
   if(ServerSide)then unit_zfall(pu);
   with pu^ do
   if(vx<>x)or(vy<>y)then
    if(IsUnitRange(transport,nil))then
    begin
       vstp:=0;
       vx  :=x;
       vy  :=y;
    end
    else
    begin
       if(vstp>UnitMoveStepTicks)and(ServerSide)then vstp:=UnitMoveStepTicks;
       if(vstp<=0)then vstp:=UnitMoveStepTicks;
       vx  +=(x-vx) div vstp;
       vy  +=(y-vy) div vstp;
       vstp-=1;
    end;
end;

function unit_ability_UACScan(pCaster:PTUnit;scan_x,scan_y:integer;Check:boolean):boolean;
begin
   unit_ability_UACScan:=false;
   with pCaster^ do
    if(iscomplete)and(reload<=0)then
    begin
       unit_ability_UACScan:=true;
       if(Check)then exit;

       unit_OrderClear(pCaster,true);
       ua_x  :=scan_x;
       ua_y  :=scan_y;
       reload:=radar_reload;
       buff[ub_Cast]:=fr_fps1;

       {$IFDEF _FULLGAME}
       if(ServerSide)and(player^.team=g_players[UIPlayer].team)then SoundPlayUnit(snd_radar,nil,nil);
       {$ENDIF}
    end;
end;

function unit_ability_HellInvuln(pCaster:PTUnit;uTarget:integer;Check:boolean):boolean;
var pTarget:PTUnit;
begin
   unit_ability_HellInvuln:=false;
   if(IsUnitRange(uTarget,@pTarget))then
   begin
      with pTarget^ do
        if(hits<=0)then exit;

      with pCaster^ do
       if(iscomplete)and(reload<=0)then
        with player^ do
         if(team=pTarget^.player^.team)and(upgr[upgr_hell_invuln]>0)and(pTarget^.buff[ub_Invuln]<=0)then
         begin
            unit_ability_HellInvuln:=true;
            if(Check)then exit;

            pTarget^.buff[ub_Invuln]:=invuln_time;
            reload:=haltar_reload;
            upgr[upgr_hell_invuln]-=1;
            {$IFDEF _FULLGAME}
            effect_LevelUp(pTarget,EID_Invuln,nil);
            {$ENDIF}
         end;
   end;
end;

procedure unit_ability_UACStrike_Shot(pu:PTUnit);
begin
   with pu^ do
   begin
      missile_add(ua_x,ua_y,vx,vy,0,MID_Blizzard,playeri,uf_ground,uf_ground,false,0,dm_Blizzard);
      {$IFDEF _FULLGAME}
      effect_UACStrikeShot(pu);
      {$ENDIF}
   end;
end;

function unit_ability_UACStrike(pCaster:PTUnit;shot_x,shot_y:integer;Check:boolean):boolean;
var i:byte;
begin
   unit_ability_UACStrike:=false;
   with pCaster^ do
    if(iscomplete)and(reload<=0)then
     with player^ do
      if(upgr[upgr_uac_rstrike]>0)then
      begin
         unit_ability_UACStrike:=true;
         if(Check)then exit;

         unit_OrderClear(pCaster,true);
         ua_x:=shot_x;
         ua_y:=shot_y;
         for i:=0 to MaxPlayers do AddToInt(@TeamVision[i],fr_fps2);
         reload:=mstrike_reload;
         upgr[upgr_uac_rstrike]-=1;
         unit_ability_UACStrike_Shot(pCaster);
         buff[ub_Cast]:=fr_fps1;
      end;
end;


procedure pushOut_all(tx,ty,tr,ignore_unum:integer;newx,newy:pinteger;FlyLevel:boolean);
const ptar_n = 1;
type TPush_tar = record
   x,y,a,b,c:integer;
end;
var ptar_l: array[0..ptar_n] of TPush_tar;
gx,gy,gx0,
gy0,gx1,gy1,
gmx,gmy,
o,u,d   : integer;
check_obstacles: boolean;
procedure pTarAdd(ax,ay,aa,ab,ac:integer);
var i,n:integer;
begin
   i:=0;
   while(i<=ptar_n)do
   begin
      if(ac<ptar_l[i].c)then break;
      i+=1;
   end;

   if(i>ptar_n)then exit;

   if(i<>ptar_n)then
     for n:=ptar_n-1 downto i do
       ptar_l[i+1]:=ptar_l[i];

   with ptar_l[i] do
   begin
      x:=ax;
      y:=ay;
      a:=aa;
      b:=ab;
      c:=ac;
   end;
end;
procedure pTarClear;
var i:byte;
begin
   for i:=0 to ptar_n do
     with ptar_l[i] do
     begin
        x:=0;
        y:=0;
        a:=0;
        b:=0;
        c:=NOTSET;
     end;
end;
begin
   pTarClear;

   if(FlyLevel)then check_obstacles:=false;

   if(not FlyLevel)then
    for u:=1 to MaxCPoints do
     with g_cpoints[u] do
      if(cpCaptureR>0)and(cpNoBuildR>0)then
      begin
         o:=tr+cpNoBuildR;
         d:=point_dist_int(cpx,cpy,tx,ty);
         if(d<o)then pTarAdd(cpx,cpy,o,0,d-o);
      end;

   for u:=1 to MaxUnits do
    with g_units[u] do
     with uid^ do
      if(hits>0)and(ukfly=_ukfly)and(unum<>ignore_unum)then
       if(speed<=0)or(not iscomplete)then
        if(not IsUnitRange(transport,nil))then
        begin
           o:=tr+_r;
           d:=point_dist_int(x,y,tx,ty);
           if(d<o)then pTarAdd(x,y,o,0,d-o);
        end;

   pushOut_2r(@tx,@ty,ptar_l[0].x,ptar_l[0].y,ptar_l[0].a,
                      ptar_l[1].x,ptar_l[1].y,ptar_l[1].a);

   if(check_obstacles)then
   begin
      pTarClear;

      gx0:=(tx-tr) div MapCellW;
      gy0:=(ty-tr) div MapCellW;
      gx1:=(tx+tr) div MapCellW;
      gy1:=(ty+tr) div MapCellW;

      for gx:=gx0 to gx1 do
      for gy:=gy0 to gy1 do
      begin
         gmx:=gx*MapCellW;
         gmy:=gy*MapCellW;
         if (0<=gx)and(gx<=map_LastCell)
         and(0<=gy)and(gy<=map_LastCell)then
           if(map_grid[gx,gy].tgc_solidlevel=mgsl_free)then continue;

         mgcell2NearestXY(tx,ty,gmx,gmy,gmx+MapCellW,gmy+MapCellW,0,@u,@o,@d);
         if(d<tr)then pTarAdd(gmx,gmy,MapCellW,MapCellW,d);
      end;

      // merge 2 cells to 1
      if(ptar_l[0].x=ptar_l[1].x)and(abs(ptar_l[0].y-ptar_l[1].y)<=MapCellW)then
      begin
         ptar_l[0].y:=min2i(ptar_l[0].y,ptar_l[1].y);
         ptar_l[0].b:=MapCellW*2;
         ptar_l[1].c:=NOTSET;
      end
      else
        if(ptar_l[0].y=ptar_l[1].y)and(abs(ptar_l[0].x-ptar_l[1].x)<=MapCellW)then
        begin
           ptar_l[0].x:=min2i(ptar_l[0].x,ptar_l[1].x);
           ptar_l[0].a:=MapCellW*2;
           ptar_l[1].c:=NOTSET;
        end;

      for u:=0 to ptar_n do
        with ptar_l[u] do
          if(c<>NOTSET)then
          begin
             mgcell2NearestXY(tx,ty,x,y,x+a,y+b,tr,@gmx,@gmy,nil);
             tx:=gmx;
             ty:=gmy;
          end;
   end;
   newx^:=tx;
   newy^:=ty;
end;


procedure BuildingNewPlace(tx,ty:integer;buid,pl:byte;newx,newy:pinteger);
var
aukfly  :boolean;
dx,dy,o,tr,
u,sr,dr :integer;
begin
   with g_uids[buid] do
   begin
      aukfly:=_ukfly;
      tr:=_r;
      //(g_players[pl].upgr[upgr_race_extbuilding[_urace]]=0)or(_isbarrack)or(_ability=uab_Teleport)
      pushOut_all(tx,ty,tr+1,0,@tx,@ty,aukfly);
   end;

   dx:=-2000;
   dy:=-2000;
   sr:=NOTSET;
   dr:=NOTSET;
   for u:=1 to MaxUnits do
    with g_units[u] do
     with uid^ do
      if(hits>0)and(speed<=0)and(ukfly=aukfly)and(iscomplete)and(playeri=pl)and(isbuildarea)then
       if(buid in ups_builder)and(not IsUnitRange(transport,nil))then
       begin
          o:=point_dist_int(x,y,tx,ty)-srange;
          if(o<dr)then
          begin
             dx:=x;
             dy:=y;
             dr:=o;
             sr:=srange;
          end;
       end;

   if(dr<NOTSET)then
   begin
      o :=point_dist_int(dx,dy,tx,ty);
      dr:=o-sr;
      if(0<=dr)then pushIn_1r(@tx,@ty,dx,dy,sr-1);
   end;

   if((tx-tr)<=0       )then tx:=tr+1;
   if((ty-tr)<=0       )then ty:=tr+1;
   if((tx+tr)>=map_size)then tx:=map_size-tr-1;
   if((ty+tr)>=map_size)then ty:=map_size-tr-1;

   newx^:=tx;
   newy^:=ty;
end;

function CheckCollisionR(tx,ty,tr,skipunit:integer;building,flylevel,check_obstacles:boolean):byte;
var u,gx,gy,gx0,gy0,gx1,gy1:integer;
begin
   CheckCollisionR:=0;

   if((tx-tr)<=0       )
   or((ty-tr)<=0       )
   or((tx+tr)>=map_size)
   or((tx+tr)>=map_size)then
   begin
      CheckCollisionR:=5;
      exit;
   end;

   for u:=1 to MaxUnits do
    if(u<>skipunit)then
     with g_punits[u]^ do
      with uid^ do
       if(hits>0)and(ukfly=flylevel)and(not IsUnitRange(transport,nil))then
        if(speed<=0)or(not iscomplete)then
         if(point_dist_int(x,y,tx,ty)<(tr+_r))then
         begin
            CheckCollisionR:=2;
            exit;
         end;

   if(flylevel)then exit;

   for u:=1 to MaxCPoints do
    with g_cpoints[u] do
     if(cpCaptureR>0)then
     begin
        if(building)
        then gx:=max2i(cpsolidr,cpNoBuildR)
        else gx:=cpsolidr;
        gx+=tr;
        if(gx<=0)then continue;
        if(point_dist_int(tx,ty,cpx,cpy)<gx)then
        begin
           CheckCollisionR:=3;
           exit;
        end;
     end;

   if(not check_obstacles)then exit;

   gx0:=(tx-tr) div MapCellW;
   gy0:=(ty-tr) div MapCellW;
   gx1:=(tx+tr) div MapCellW;
   gy1:=(ty+tr) div MapCellW;

   for gx:=gx0 to gx1 do
   for gy:=gy0 to gy1 do
   if (0<=gx)and(gx<=map_LastCell)
   and(0<=gy)and(gy<=map_LastCell)then
   begin
      if(map_grid[gx,gy].tgc_solidlevel=mgsl_free)then continue;

      u:=dist2mgcellC(tx,ty,gx,gy);
      if(u<tr)then
      begin
         CheckCollisionR:=4;
         exit;
      end;
   end;
end;

function CheckBuildArea(tx,ty,tr:integer;buid,pl:byte):byte;
var u:integer;
tzone:word;
begin
   CheckBuildArea:=0;

   if(pl<=MaxPlayers)then
    with g_players[pl] do
     if(n_builders<=0)then
     begin
        CheckBuildArea:=1; // no builders
        exit;
     end;

   for u:=1 to MaxCPoints do
    with g_cpoints[u] do
     if(cpCaptureR>0)and(cpNoBuildR>0)then
      if(point_dist_int(tx,ty,cpx,cpy)<cpNoBuildR)then
      begin
         CheckBuildArea:=2;
         exit;
      end;

   tr+=g_uids[buid]._r;

   CheckBuildArea:=2;

   tzone:=map_MapGetZone(tx,ty);

   for u:=1 to MaxUnits do
    with g_punits[u]^ do
     with uid^ do
      if(hits>0)and(iscomplete)and(isbuildarea)and(playeri=pl)then
       if(abs(x-tx)<=srange)and(abs(y-ty)<=srange)and(tzone=zone)then
        if(buid in ups_builder)and(not IsUnitRange(transport,nil))then
         if(point_dist_int(x,y,tx,ty)<srange)then
         begin
            CheckBuildArea:=0; // inside build area
            break;
         end;
end;

function CheckBuildPlace(tx,ty,tr,uskip:integer;playern,buid:byte):byte;
var i:byte;
obstacles:boolean;
begin
   CheckBuildPlace:=0;

   {
   0 :  m_brushc:=c_lime;
   1 :  m_brushc:=c_red;
   2 :  m_brushc:=c_blue;
   else m_brushc:=c_gray;
   }

   obstacles:=true;
   if(playern<=MaxPlayers)then
   begin
      //with g_uids[buid] do
      //  with g_players[playern] do
      //    obstacles:=(upgr[upgr_race_extbuilding[_urace]]=0)or(_isbarrack)or(_ability=uab_Teleport);

      //if(obstacles)and(g_players[playern].player_type=pt_ai)then
      //  if(map_IsObstacleZone(map_MapGetZone(tx,ty)))then begin CheckBuildPlace:=2;exit;end;
   end;

   i:=CheckBuildArea(tx,ty,0,buid,playern); // 0=inside; 1=outside; 2=no builders
   case i of
   0  : ;
   2  : begin CheckBuildPlace:=2;exit;end;
   else begin CheckBuildPlace:=3;exit;end;
   end;

   with g_uids[buid] do
     i:=CheckCollisionR(tx,ty,tr+_r,uskip,_ukbuilding,_ukfly,obstacles);
   if(i>0)then CheckBuildPlace:=1;
end;


function unit_ability_HellLBlink(pCaster:PTUnit;blink_x,blink_y:integer;Check:boolean):boolean;
var obstacles:boolean;
begin
   unit_ability_HellLBlink:=false;
   with pCaster^ do
    if(hits>0)and(iscomplete)and(buff[ub_CCast]<=0)then
     with uid^ do
     with player^ do
      if(upgr[upgr_hell_HKTeleport]>0)then
      begin
         obstacles:=true;//(upgr[upgr_race_extbuilding[_urace]]=0)or(_isbarrack)or(_ability=uab_Teleport);
         pushOut_all(blink_x,blink_y,_r,unum,@blink_x,@blink_y,ukfly);
         blink_x:=mm3i(1,blink_x,map_size);
         blink_y:=mm3i(1,blink_y,map_size);
         if(CheckCollisionR(blink_x,blink_y,_r,unum,_ukbuilding,ukfly,obstacles)>0)then exit;

         unit_ability_HellLBlink:=true;
         if(Check)then exit;

         upgr[upgr_hell_HKTeleport]-=1;
         buff[ub_CCast]:=fr_fps1;

         case uidi of
         UID_HKeep : unit_teleport(pCaster,blink_x,blink_y{$IFDEF _FULLGAME},EID_HKeep_H ,EID_HKeep_S ,snd_cube    {$ENDIF});
         UID_HAKeep: unit_teleport(pCaster,blink_x,blink_y{$IFDEF _FULLGAME},EID_HAKeep_H,EID_HAKeep_S,snd_cube    {$ENDIF});
         else        unit_teleport(pCaster,blink_x,blink_y{$IFDEF _FULLGAME},EID_Teleport,EID_Teleport,snd_teleport{$ENDIF});
         end;
      end;
end;

function unit_ability_HellSBlink(pCaster:PTUnit;blink_x,blink_y:integer;Check:boolean):boolean;
var obstacles:boolean;
begin
   unit_ability_HellSBlink:=false;
   with pCaster^ do
    if(hits>0)and(iscomplete)and(buff[ub_CCast]<=0)then
     with uid^ do
     with player^ do
      if(upgr[upgr_hell_tblink]>0)then
      begin
         obstacles:=true;//(upgr[upgr_race_extbuilding[_urace]]=0)or(_isbarrack)or(_ability=uab_Teleport);
         if(srange<point_dist_int(x,y,blink_x,blink_y))then pushIn_1r(@blink_x,@blink_y,x,y,srange-1);
         pushOut_all(blink_x,blink_y,_r,unum,@blink_x,@blink_y,ukfly  );
         blink_x:=mm3i(1,blink_x,map_size);
         blink_y:=mm3i(1,blink_y,map_size);
         if(point_dist_int(x,y,blink_x,blink_y)>srange)then exit;
         if(CheckCollisionR(blink_x,blink_y,_r,unum,_ukbuilding,ukfly,obstacles)>0)then exit;

         unit_ability_HellSBlink:=true;
         if(Check)then exit;

         upgr[upgr_hell_tblink]-=1;
         buff[ub_CCast]:=fr_fpsd2;
         unit_teleport(pCaster,blink_x,blink_y{$IFDEF _FULLGAME},EID_Teleport,EID_Teleport,snd_teleport{$ENDIF});
      end;
end;

function unit_ability_HellRecall(pCaster:PTUnit;uTarget,targetd:integer;Check:boolean):boolean;
var pTarget:PTUnit;
begin
   // pCaster - teleporter
   unit_ability_HellRecall:=false;
   if(not IsUnitRange(uTarget,@pTarget))then exit;

   with pTarget^ do
   with uid^ do
     if(_ukbuilding)
     or(not iscomplete)
     or(ukfly)
     or(hits<=0)
     or(buff[ub_Teleport]>0)
     then exit;

   with pCaster^ do
     if(playeri<>playeri)
     or(not iscomplete)
     or(hits<=0)
     then exit;

    with pCaster^  do
     with uid^ do
      with player^ do
       if(upgr[upgr_hell_rteleport]>0)then
       begin
          if(targetd=NOTSET )
          or(targetd<0      )then targetd:=point_dist_int(x,y,pTarget^.x,pTarget^.y);
          if(targetd>base_1r)then
            if(reload<=0)then
            begin
               unit_ability_HellRecall:=true;
               if(Check)then exit;

               unit_teleport(pTarget,x,y{$IFDEF _FULLGAME},EID_Teleport,EID_Teleport,snd_teleport{$ENDIF});
               teleport_SetReloadTimer(pCaster,pTarget^.uid^._limituse);
               unit_OrderClear(pTarget,true);
            end;
       end;
end;

function ability_teleport(pTarget,pTeleporter:PTUnit;td:integer):boolean;
var
pTeleportMarker:PTUnit;
tr             :integer;
begin
   // td = dist2(pTarget,pTeleporter)
   if(td=NOTSET)then td:=point_dist_int(pTarget^.x,pTarget^.y,pTeleporter^.x,pTeleporter^.y);
   ability_teleport:=false;
   with pTarget^ do
    with uid^    do
      if(not _ukbuilding)and(iscomplete)and(not ukfly)and(pTeleporter^.hits>0)and(pTeleporter^.iscomplete)then
       if(playeri=pTeleporter^.playeri)and(buff[ub_Teleport]<=0)then
        if(td<=pTeleporter^.uid^._r)then
        begin
           if(pTeleporter^.reload<=0)then
           begin
              if(not IsUnitRange(pTeleporter^.ua_tar,@pTeleportMarker))then exit;
              if(pTeleportMarker^.player^.team<>pTeleporter^.player^.team)then exit;
              if(pTeleportMarker^.hits<=0)then exit;

              if(ukfly=uf_ground)then
                if(map_IsObstacleZone(pTeleportMarker^.zone))then exit;
              pTeleporter^.ua_x:=pTeleportMarker^.x;
              pTeleporter^.ua_y:=pTeleportMarker^.y;

              tr:=_r+pTeleportMarker^.uid^._r;

              if(ukfly=pTeleportMarker^.ukfly)
              then unit_teleport(pTarget,pTeleporter^.ua_x+(tr*sign(x-pTeleporter^.ua_x)),pTeleporter^.ua_y{$IFDEF _FULLGAME},EID_Teleport,EID_Teleport,snd_teleport{$ENDIF})
              else unit_teleport(pTarget,pTeleporter^.ua_x                               ,pTeleporter^.ua_y{$IFDEF _FULLGAME},EID_Teleport,EID_Teleport,snd_teleport{$ENDIF});

              teleport_SetReloadTimer(pTeleporter,_limituse);
              ability_teleport:=true;
           end;
        end
        else
          if(pTeleporter^.player^.upgr[upgr_hell_rteleport]>0)and(td>base_1r)then
            if(pTeleporter^.reload<=0)then
            begin
               unit_teleport(pTarget,pTeleporter^.x,pTeleporter^.y{$IFDEF _FULLGAME},EID_Teleport,EID_Teleport,snd_teleport{$ENDIF});
               teleport_SetReloadTimer(pTeleporter,_limituse);
               ua_x  :=x;
               ua_y  :=y;
               ua_tar:=0;
               ability_teleport:=true;
            end
            else
            begin
               ua_x  :=x;
               ua_y  :=y;
               ability_teleport:=true;
            end;
end;


procedure unit_SetDefaults(pu:PTUnit;ClientSide:boolean);
begin
   with pu^ do
   begin
      if(not ClientSide)then
      begin
         transport:= 0;
         a_tar    := 0;
         a_weap   := 0;
      end;

      ua_id     := ua_attack;
      ua_tar    := 0;
      reload    := 0;
      pains     := 0;
      dir       := 270;
      group     := 0;
      a_reload  := 0;
      a_shots   := 0;
      a_weap_cl := 0;
      a_tar_cl  := 0;
      a_exp     := 0;
      a_exp_next:= ExpLevel1;

      aiu_alarm_timer :=0;
      aiu_alarm_d     :=NOTSET;
      aiu_alarm_x     :=-1;
      aiu_alarm_y     :=0;
      aiu_need_detect :=NOTSET;
      aiu_limitaround_ally :=0;
      aiu_limitaround_enemy:=0;
      aiu_FiledSquareNear  :=0;

      FillChar(uprod_r,SizeOf(uprod_r),0);
      FillChar(pprod_r,SizeOf(pprod_r),0);
      FillChar(pprod_e,SizeOf(pprod_e),0);
      FillChar(uprod_u,SizeOf(uprod_u),0);
      FillChar(pprod_u,SizeOf(pprod_u),0);

      {$IFDEF _FULLGAME}
      wanim    := false;
      anim     := 0;
      unit_UpdateMiniMapXY(pu);
      unit_UpdateFogXY    (pu);
      {$ENDIF}
   end;
end;

procedure unit_PC_done_inc(pu:PTUnit);
begin
   with pu^ do
   with uid^ do
   with player^ do
   begin
      if(_isbuilder  )then n_builders  +=1;
      if(_isbarrack  )then
      begin
         n_barracks+=1;
         uprodm+=level+1;
      end;
      if(_issmith    )then
      begin
         n_smiths+=1;
         upprodm+=level+1;
      end;
   end;
end;
procedure unit_PC_done_dec(pu:PTUnit);
begin
   with pu^ do
   with uid^ do
   with player^ do
   begin
      if(_isbuilder  )then n_builders  -=1;
      if(_isbarrack  )then
      begin
         n_barracks-=1;
         uprodm-=level+1;
      end;
      if(_issmith    )then
      begin
         n_smiths-=1;
         upprodm-=level+1;
      end;
   end;
end;

procedure unit_PC_complete_inc(pu:PTUnit);
begin
   with pu^ do
   with uid^ do
   with player^ do
   begin
      if(uid_x[uidi            ]<=0)then uid_x[uidi            ]:=unum;
      if(ucl_x[_ukbuilding,_ucl]<=0)then ucl_x[_ukbuilding,_ucl]:=unum;
      ucl_eb[_ukbuilding,_ucl]+=1;
      uid_eb[uidi            ]+=1;
      menergy+=_genergy;
      cenergy+=_genergy;
      unit_PC_done_inc(pu);
   end;
end;

procedure unit_PC_add_inc(pu:PTUnit;aiscomplete,asummoned:boolean);
begin
   with pu^     do
   with uid^    do
   with player^ do
   begin
      army+=1;
      armylimit+=_limituse;
      ucl_e[_ukbuilding,_ucl]+=1;
      ucl_c[_ukbuilding     ]+=1;
      ucl_l[_ukbuilding     ]+=_limituse;
      uid_e[uidi            ]+=1;

      iscomplete:=aiscomplete;

      if(iscomplete)
      then unit_PC_complete_inc(pu)
      else
      begin
         hits  := 1;
         cenergy-=_renergy;
         {$IFDEF _FULLGAME}
         if(playeri=UIPlayer)then SoundPlayAnoncer(snd_build_place[_urace],false,false);
         {$ENDIF}
      end;

      if(asummoned)and(iscomplete)then
      begin
         buff[ub_Summoned]:=fr_fps1;
         {$IFDEF _FULLGAME}
         effect_UnitSummon(LastCreatedUnitP,nil);
         {$ENDIF}
      end;
   end;
end;

function unit_add(ux,uy,aunum:integer;uuid,uplayer:byte;ubld,summoned:boolean;ulevel:byte):cardinal;
procedure FindNotExistedUnit;
var i:integer;
begin
   i:=MaxPlayerUnits*uplayer+1;
   for i:=i to i+MaxPlayerUnits do
    with g_units[i] do
     if(hits<=dead_hits)then
     begin
        LastCreatedUnit :=i;
        LastCreatedUnitP:=g_punits[i];
        break;
     end;
end;
begin
   unit_add:=0;
   LastCreatedUnit :=0;
   LastCreatedUnitP:=g_punits[0];
   with g_players[uplayer] do
   if(uuid=0)
   then unit_add:=ureq_unknown
   else
   begin
      if(not IsUnitRange(aunum,nil))
      then FindNotExistedUnit
      else
        if(g_units[aunum].hits>dead_hits)
        then FindNotExistedUnit
        else
        begin
           LastCreatedUnit :=aunum;
           LastCreatedUnitP:=@g_units[LastCreatedUnit];
        end;

      if(LastCreatedUnit=0)
      then unit_add:=ureq_unknown
      else
      begin
         FillChar(LastCreatedUnitP^,SizeOf(TUnit),0);

         with LastCreatedUnitP^ do
         begin
            {$IFDEF _FULLGAME}
            mmap_order := LastCreatedUnit mod vid_blink_period1;
            {$ENDIF}
            cycle_order:= LastCreatedUnit mod order_period;
            unum       := LastCreatedUnit;

            x          := ux;
            y          := uy;
            vx         := x;
            vy         := y;
            uidi       := uuid;
            playeri    := uplayer;
            player     :=@g_players[playeri];
            ua_x       := x;
            ua_y       := y;
            ua_bx      := -1;
            ua_by      := -1;
            moveCurr_x := x;
            moveCurr_y := y;
            gridx      := x div MapCellW;
            gridy      := y div MapCellW;
            zone       := map_CellGetZone(gridx,gridy);
            isselected := false;
            transportC := 0;

            FillChar(buff,sizeof(buff),0);
            FillChar(TeamVision,SizeOf(TeamVision),0);
            FillChar(TeamDetection,SizeOf(TeamDetection),0);

            if(ulevel>MaxUnitLevel)
            then ulevel:=MaxUnitLevel;
            level:=ulevel;

            unit_SetDefaults(LastCreatedUnitP,false);
            unit_BaseVision (LastCreatedUnitP,false);
            unit_apllyUID   (LastCreatedUnitP);
            unit_PC_add_inc (LastCreatedUnitP,ubld,summoned);
         end;
      end;
   end;
end;

function StartBuild(bx,by:integer;buid,bplayer:byte):cardinal;
begin
   StartBuild:=uid_CheckRequirements(@g_players[bplayer],buid);
   if(StartBuild=0)then
    with g_players[bplayer] do
     if(CheckBuildPlace(bx,by,0,0,bplayer,buid)=0)
     then unit_add(bx,by,-1,buid,bplayer,false,false,0)
     else StartBuild:=ureq_place;
end;

function barrack_out_RStep(pu:PTUnit;_uid:byte):integer;
begin
   if(g_uids[_uid]._ukfly=uf_fly)
   then barrack_out_RStep:=0
   else barrack_out_RStep:=pu^.uid^._r;//+g_uids[_uid]._r;
end;

function barrack_out_unit(pu:PTUnit;_uid:byte;_sstep,_dir:integer):boolean;
var
cd    :single;
begin
   barrack_out_unit:=false;
   with pu^ do
   with uid^ do
   begin
      cd:=_dir*degtorad;

      if(_sstep<0)
      then _sstep:=barrack_out_RStep(pu,_uid);

      if(_sstep=0)
      then unit_add(x,y,-1,_uid,playeri,true,false,0)
      else unit_add(x+trunc(_sstep*cos(cd)),
                    y-trunc(_sstep*sin(cd)),-1,_uid,playeri,true,false,0);

      if(LastCreatedUnit>0)then
      begin
         LastCreatedUnitP^.ua_x  :=ua_x;
         LastCreatedUnitP^.ua_y  :=ua_y;
         LastCreatedUnitP^.ua_id :=ua_id;
         LastCreatedUnitP^.ua_tar:=ua_tar;
         LastCreatedUnitP^.dir   :=dir;

         if(_barrack_teleport)then
         begin
            LastCreatedUnitP^.buff[ub_Teleport]:=fr_fps1;
            {$IFDEF _FULLGAME}
            if(SoundPlayUnit(snd_teleport,pu,nil))
            then effect_add(LastCreatedUnitP^.vx,
                            LastCreatedUnitP^.vy,SpriteDepth(LastCreatedUnitP^.vy+1,LastCreatedUnitP^.ukfly),EID_Teleport);
            {$ENDIF}
         end;
         barrack_out_unit:=true;
      end;
   end;

end;

procedure barrack_ProductionEnd(pu:PTUnit;_uid,count:byte);
var sstep,i  :integer;
    announcer:boolean;
begin
   with pu^ do
   with uid^ do
   begin
      dir  :=point_dir(x,y,ua_x,ua_y);
      sstep:=barrack_out_RStep(pu,_uid);

      announcer:=false;

      for i:=0 to count do announcer:=barrack_out_unit(pu,_uid,sstep,dir+i*15) or announcer;

      if(announcer)
      then GameLogUnitReady(LastCreatedUnitP);
   end;
end;

//////   Start unit prod
//
function unit_ProdUnitStart_p(pu:PTUnit;puid,pn:byte):boolean;
begin
   unit_ProdUnitStart_p:=false;
   if(0<puid)and(puid<255)then
     with pu^ do
     with uid^ do
       if(hits>0)and(iscomplete)and(_isbarrack)then
         if not(puid in ups_units)
         then PlayerSetProdError(playeri,lmt_argt_unit,puid,ureq_barracks,pu)
         else
           if(uprod_r[pn]>0)
           then PlayerSetProdError(playeri,lmt_argt_unit,puid,ureq_busy,pu)
           else
             if(not PlayerSetProdError(playeri,lmt_argt_unit,puid,uid_CheckRequirements(pu^.player,puid),pu))then
               with player^ do
               begin
                  uproda+=1;
                  uprodl+=g_uids[puid]._limituse;
                  uprodc[g_uids[puid]._ucl]+=1;
                  uprodu[ puid           ]+=1;
                  cenergy-=g_uids[puid]._renergy;
                  uprod_u[pn]:=puid;
                  uprod_r[pn]:=g_uids[puid]._tprod;

                  unit_ProdUnitStart_p:=true;
               end;
end;
function unit_ProdUnitStart(pu:PTUnit;puid:byte):boolean;  // main function
var i:byte;
begin
   unit_ProdUnitStart:=true;

   for i:=0 to MaxUnitLevel do
   begin
      if(i>pu^.level)then break;
      if(unit_ProdUnitStart_p(pu,puid,i))then exit;
   end;

   unit_ProdUnitStart:=false;
end;
/// Stop unit prod
function unit_ProdUnitStop_p(pu:PTUnit;puid,pn:byte):boolean;
begin
   unit_ProdUnitStop_p:=false;
   with pu^ do
   with uid^ do
     if(uprod_r[pn]>0)and(iscomplete)and(_isbarrack)then
       if(puid=255)or(puid=uprod_u[pn])then
         with player^ do
         begin
            puid:=uprod_u[pn];

            uproda-=1;
            uprodl-=g_uids[puid]._limituse;
            uprodc[g_uids[puid]._ucl]-=1;
            uprodu[ puid           ]-=1;
            cenergy+=g_uids[puid]._renergy;
            uprod_r[pn]:=0;

            unit_ProdUnitStop_p:=true;
         end;
end;
function unit_ProdUnitStop(pu:PTUnit;puid:byte;StopAll:boolean):boolean;
var i:byte;
begin
   unit_ProdUnitStop:=false;

   for i:=MaxUnitLevel downto 0 do
     if(unit_ProdUnitStop_p(pu,puid,i))then
     begin
        unit_ProdUnitStop:=true;
       if(not StopAll)then break;
     end;
end;


//////   Start upgrade production
//
function unit_ProdUpgrStart_p(pu:PTUnit;upid,pn:byte):boolean;
begin
   unit_ProdUpgrStart_p:=false;
   if(0<upid)and(upid<255)then
     with pu^ do
     with uid^ do
       if(hits>0)and(iscomplete)and(_issmith)then
         if not(upid in ups_upgrades)
         then PlayerSetProdError(playeri,lmt_argt_upgr,upid,ureq_smiths,pu)
         else
           if(pprod_r[pn]>0)
           then PlayerSetProdError(playeri,lmt_argt_upgr,upid,ureq_busy,pu)
           else
             if(not PlayerSetProdError(playeri,lmt_argt_upgr,upid,upid_CheckRequirements(player,upid),pu))then
               with player^ do
               with g_upids[upid] do
               begin
                  upproda+=1;
                  upprodu[upid]+=1;
                  pprod_e[pn]:=upid_CalcCostEnergy(upid,upgr[upid]+1);
                  cenergy-=pprod_e[pn];
                  pprod_r[pn]:=upid_CalcCostTime(upid,upgr[upid]+1);
                  pprod_u[pn]:=upid;

                  unit_ProdUpgrStart_p:=true;
               end;
end;
function unit_ProdUpgrStart(pu:PTUnit;upid:integer):boolean;
var i:byte;
begin
   unit_ProdUpgrStart:=true;

   for i:=0 to MaxUnitLevel do
   begin
      if(i>pu^.level)then break;
      if(unit_ProdUpgrStart_p(pu,upid,i))then exit;
   end;

   unit_ProdUpgrStart:=false;
end;
function unit_ProdUpgrStop_p(pu:PTUnit;upid:byte;pn:integer):boolean;
begin
   unit_ProdUpgrStop_p:=false;
   with pu^ do
   with uid^ do
     if(pprod_r[pn]>0)and(iscomplete)and(_issmith)then
       if(upid=255)or(upid=pprod_u[pn])then
         with player^ do
         begin
            upid:=pprod_u[pn];

            upproda-=1;
            upprodu[upid]-=1;
            cenergy+=pprod_e[pn]; //g_upids[upid]._up_renerg;
            pprod_r[pn]:=0;

            unit_ProdUpgrStop_p:=true;
         end;
end;
function unit_ProdUpgrStop(pu:PTUnit;puid:byte;StopAll:boolean):boolean;
var i:byte;
begin
   unit_ProdUpgrStop:=false;

   for i:=MaxUnitLevel downto 0 do
     if(unit_ProdUpgrStop_p(pu,puid,i))then
     begin
        unit_ProdUpgrStop:=true;
        if(not StopAll)then break;
     end;
end;

procedure unit_PC_select_inc(pu:PTUnit);
begin
   with pu^ do
   with uid^ do
   with player^ do
   begin
      ucl_s [_ukbuilding,_ucl]+=1;
      ucl_cs[_ukbuilding     ]+=1;
      uid_s [uidi            ]+=1;
      if(_isbuilder)then s_builders+=1;
      if(_isbarrack)then s_barracks+=1;
      if(_issmith  )then s_smiths  +=1;
   end;
end;
procedure unit_PC_select_dec(pu:PTUnit);
begin
   with pu^ do
   with uid^ do
   with player^ do
   begin
      ucl_s [_ukbuilding,_ucl]-=1;
      ucl_cs[_ukbuilding     ]-=1;
      uid_s [uidi            ]-=1;
      if(_isbuilder)then s_builders-=1;
      if(_isbarrack)then s_barracks-=1;
      if(_issmith  )then s_smiths  -=1;
   end;
end;

procedure unit_UnSelect(pu:PTUnit);
begin
   with pu^ do
   begin
      if(isselected)then unit_PC_select_dec(pu);
      isselected:=false;
   end;
end;

procedure unit_PC_base_dec(pu:PTUnit);
begin
   with pu^ do
   with uid^ do
   with player^ do
   begin
      unit_UnSelect(pu);

      if(iscomplete=false)
      then cenergy+=g_uids[uidi]._renergy
      else
      begin
         unit_ProdUnitStop(pu,255,true);
         unit_ProdUpgrStop(pu,255,true);

         ucl_eb[_ukbuilding,_ucl]-=1;
         uid_eb[uidi            ]-=1;
         menergy-=_genergy;
         cenergy-=_genergy;

         unit_PC_done_dec(pu);
      end;

      if(ucl_x[_ukbuilding,_ucl]=unum)then ucl_x[_ukbuilding,_ucl]:=0;
      if(uid_x[uidi            ]=unum)then uid_x[uidi            ]:=0;
   end;
end;

procedure unit_PC_add_dec(pu:PTUnit);
begin
   with pu^ do
   with uid^ do
   with player^ do
   begin
      army     -=1;
      armylimit-=_limituse;
      ucl_e[_ukbuilding,_ucl]-=1;
      ucl_c[_ukbuilding     ]-=1;
      ucl_l[_ukbuilding     ]-=_limituse;
      uid_e[uidi            ]-=1;
   end;
end;

procedure unit_ProdUnitEnd(pu:PTUnit);
var i,_uid:byte;
begin
   with pu^ do
   with uid^ do
     if(_isbarrack)then
       with player^ do
         for i:=0 to MaxUnitLevel do
           if(uprod_r[i]>0)then
           begin
              _uid:=uprod_u[i];

              if((army     +uproda)>MaxPlayerUnits)
              or((armylimit+uprodl)>MaxPlayerLimit)
              or(cenergy<0)
              or(uid_e[_uid]>=a_units[_uid])
              then
              else
                if(uprod_r[i]=1){$IFDEF _FULLGAME}or(test_fastprod){$ENDIF}then
                begin
                   barrack_ProductionEnd(pu,uprod_u[i],upgr[upgr_mult_product]);
                   unit_ProdUnitStop_p(pu,255,i);
                end
                else uprod_r[i]:=max2i(1,uprod_r[i]-1*(upgr[upgr_fast_product]+1) );
           end;
end;

procedure unit_ProdUpgrEnd(pu:PTUnit);
var i,_uid:byte;
begin
   with pu^ do
   with uid^ do
     if(_issmith)then
       with player^ do
         for i:=0 to MaxUnitLevel do
           if(pprod_r[i]>0)then
           begin
              _uid:=pprod_u[i];
              if(cenergy<0)
              or(upgr[_uid]>=g_upids[_uid]._up_max)
              or(upgr[_uid]>=a_upgrs[_uid])
              then
              else
                if(pprod_r[i]=1){$IFDEF _FULLGAME}or(test_fastprod){$ENDIF}then
                begin
                   upgr[_uid]+=1;
                   unit_ProdUpgrStop_p(pu,255,i);
                   GameLogUpgradeComplete(playeri,_uid,x,y);
                end
                else pprod_r[i]:=max2i(1,pprod_r[i]-1*(upgr[upgr_fast_product]+1) );
           end;
end;

procedure ability_SpawnUnit(pu:PTUnit;tx,ty:integer;auid:byte);
var tu:PTUnit;
begin
   with pu^ do
   with player^ do
   begin
      if(not uid_CheckPlayerLimit(player,auid))
      then LastCreatedUnit:=0
      else
        if(not ServerSide)
        then LastCreatedUnit:=1
        else unit_add(tx,ty,-1,auid,playeri,true,true,0);

      if(LastCreatedUnit>0)then
      begin
         if(ServerSide)then
         begin
            LastCreatedUnitP^.dir   :=dir;
            LastCreatedUnitP^.a_tar :=a_tar;
            LastCreatedUnitP^.ua_id :=ua_id;
            LastCreatedUnitP^.ua_tar:=ua_tar;
            if(IsUnitRange(a_tar,@tu))then
            begin
               LastCreatedUnitP^.ua_x :=tu^.x;
               LastCreatedUnitP^.ua_y :=tu^.y;
            end
            else
             if(ua_x<>x)or(ua_y<>y)then
             begin
                LastCreatedUnitP^.ua_x:=ua_x;
                LastCreatedUnitP^.ua_y:=ua_y;
             end;
         end
         else LastCreatedUnit:=0;
      end
      {$IFDEF _FULLGAME}
      else
        case auid of
UID_Phantom : effect_Common(tx,ty,SpriteDepth(ty+1,ukfly),nil,auid,snd_pexp);
UID_LostSoul: effect_Common(tx,ty,SpriteDepth(ty+1,ukfly),nil,auid,snd_pexp);
        end;
      {$ENDIF};
   end;
end;


procedure ability_SpawnUnitStep(pu:PTUnit;auid:byte);
var dd:integer;
begin
   with pu^ do
   with uid^ do
   begin
      dd:=DIR360(dir+23) div 45;
      ability_SpawnUnit(pu,x+dir_stepX[dd]*_r,y+dir_stepY[dd]*_r,auid);
   end;
end;

function unit_CheckTransport(pTransport,pTarget:PTUnit):boolean;
begin
   //pTransport - transport
   //pTarget - target
   unit_CheckTransport:=false;
   if(pTarget^.ukfly=uf_fly)
   or(pTransport=pTarget)
   or(pTransport^.player<>pTarget^.player)then exit;

   if((pTransport^.transportM-pTransport^.transportC)>=pTarget^.uid^._transportS)then
     if(pTarget^.uidi in pTransport^.uid^.ups_transport)then unit_CheckTransport:=true;
end;

procedure unit_BaseCounters(pu:PTUnit);
var i:byte;
begin
   with pu^ do
   begin
      for i:=0 to MaxUnitBuffs do
        if(0<buff[i])and(buff[i]<_ub_infinity)then buff[i]-=1;

      for i:=0 to MaxPlayers do
      begin
         if(0<TeamVision[i])and(TeamVision[i]<_ub_infinity)then TeamVision[i]-=1;
         if(0<TeamDetection[i])and(TeamDetection[i]<_ub_infinity)then TeamDetection[i]-=1;
      end;

      if(iscomplete)then
      begin
         if(  reload>0)then   reload-=1;
         if(a_reload>0)then a_reload-=1;
      end;
   end;
end;


procedure unit_detect(uu,tu:PTUnit;ud:integer);
var td:integer;
scan_buff:byte;
begin
   // tu - unit-detector
   // uu - unit-target
   scan_buff:=255;
   with uu^ do
   begin
      if(tu^.player^.isobserver)
      or((tu^.player^.upgr[upgr_fog_vision]>0)and(tu^.buff[ub_detect]<=0))
      then td:=0
      else
        if(tu^.uid^._ability=uab_UACScan)and(tu^.reload>radar_vision_time)then
        begin
           td:=point_dist_int(x,y,tu^.ua_x,tu^.ua_y);
           if(td<ud)
           then scan_buff:=ub_Scaned
           else td:=ud;
        end
        else td:=ud;

      if(td<=(tu^.srange+uid^._r))then
        if(buff[ub_Invis]<=0)then
        begin
           AddToInt(@TeamVision[tu^.player^.team],MinVisionTime);
           if(scan_buff<=MaxUnitBuffs)and(player^.team<>tu^.player^.team)
           then AddToInt(@buff[scan_buff],MinVisionTime);
        end
        else
          if(tu^.buff[ub_Detect]>0)and(tu^.iscomplete)and(tu^.hits>0)then
          begin
             AddToInt(@TeamVision[tu^.player^.team],MinVisionTime);
             AddToInt(@TeamDetection[tu^.player^.team],MinVisionTime);
             if(scan_buff<=MaxUnitBuffs)and(player^.team<>tu^.player^.team)
             then AddToInt(@buff[scan_buff],MinVisionTime);
          end;
   end;
end;


procedure unit_remove(pu:PTUnit);
begin
   with pu^ do
    with player^ do
    begin
       unit_PC_add_dec(pu);

       //if(G_Status=gs_running)then
        if(playeri>0)or(g_mode<>gm_invasion)then
         if(army<=0)and(player_type>pt_none)//{$IFDEF _FULLGAME}and(menu_s2<>ms2_camp){$ENDIF}
         then GameLogPlayerDefeated(playeri);
    end;
end;

procedure unit_kill(pu:PTUnit;instant,fastdeath,buildcd,KillAllInside,suicide:boolean);
var i :integer;
    tu:PTunit;
begin
   with pu^ do
   if(hits>0)then
   with player^ do
   begin
      if(not instant)then
      begin
         with uid^ do fastdeath:=(fastdeath)or(_fastdeath_hits>=0)or(_ukbuilding);
         buff[ub_Pain]:=fr_fps1; // prevent fast resurrecting

         if(not suicide)then GameLogUnitAttacked(pu);
         {$IFDEF _FULLGAME}
         effect_UnitDeath(pu,fastdeath,nil);
         {$ENDIF}
      end;

      {$IFDEF _FULLGAME}
      if(unum=ui_UnitSelectedPU)then ui_UnitSelectedPU:=0;
      {$ENDIF}

      unit_PC_base_dec(pu);

      with uid^ do
      begin
         if(_ukbuilding)and(buildcd)then
           if(_ability<>uab_HellVision)or(not iscomplete)then build_cd:=min2i(build_cd+step_build_reload,max_build_reload);
         zfall:=_zfall;
      end;

      x       :=vx;
      y       :=vy;
      unit_OrderClear(pu,true);
      moveCurr_x    :=x;
      moveCurr_y    :=y;
      a_tar   :=0;
      a_reload:=0;
      reload  :=0;

      for i:=1 to MaxUnits do
      if(i<>unum)then
      begin
         tu:=@g_units[i];
         if(tu^.hits>0)then
         begin
            if(tu^.ua_tar=unum)then tu^.ua_tar:=0;
            if(transportC>0)then
             if(tu^.transport=unum)then
             begin
                if(ukfly<>uf_ground)or(transport>0)or(KillAllInside)
                then unit_kill(tu,true,false,true,KillAllInside,suicide)
                else
                begin
                   tu^.transport:=0;
                   transportC-=tu^.uid^._transportS;
                   tu^.x+=g_randomr(uid^._r);
                   tu^.y+=g_randomr(uid^._r);
                   tu^.ua_x:=tu^.x;
                   tu^.ua_y:=tu^.y;
                   if(tu^.hits>apc_exp_damage)
                   then tu^.hits-=apc_exp_damage
                   else unit_kill(tu,true,false,true,false,suicide);
                end;
             end;
         end
         else tu^.transport:=0;
      end;
      missiles_TargetClear(unum,false);

      if(instant)then
      begin
         hits:=ndead_hits;
         unit_remove(pu);
      end
      else
      begin
         if(fastdeath)
         then hits:=fdead_hits
         else hits:=0;

         with uid^ do
         begin
            if(_death_missile>0)
            then missile_add(x,y,x,y,0,_death_missile,playeri,ukfly,ukfly,false,0,_death_missile_dmod);
            if(_death_uid>0)and(_death_uidn>0)then
              for i:=1 to _death_uidn do
                if(uid_CheckPlayerLimit(player,_death_uid))then
                  unit_add(x-g_randomr(_missile_r),y-g_randomr(_missile_r),0,_death_uid,playeri,true,true,0);
         end;
      end;
   end
   else
     if(hits>dead_hits)then
     begin
        hits:=ndead_hits;
        unit_remove(pu);
     end;
end;

function unit_ability_HellVision(pCaster:PTUnit;uTarget:integer;Check:boolean):boolean;
var pTarget:PTUnit;
begin
   unit_ability_HellVision:=false;
   if(not IsUnitRange(uTarget,@pTarget))then exit;
   with pCaster^ do
   with player^ do
     if(iscomplete)and(hits>0)and(reload<=0)and(pTarget^.iscomplete)and(pTarget^.hits>0)and(team=pTarget^.player^.team)then
       if(pTarget^.buff[ub_HVision]<fr_fps1)and(pTarget^.buff[ub_Detect]<=0)then
       begin
          unit_ability_HellVision:=true;
          if(Check)then exit;

          pTarget^.buff[ub_HVision]:=hell_vision_time;
          unit_kill(pCaster,false,true,false,false,true);
          {$IFDEF _FULLGAME}
          effect_LevelUp(pTarget,EID_Hvision,nil);
          {$ENDIF}
       end;
end;

procedure unit_Bonuses(pu:PTUnit);
var tu:PTUnit;
    t :integer;
procedure SetSRange(newsr:integer);
begin
   with pu^ do
   if(srange<>newsr)then
   begin
      srange:=newsr;
      {$IFDEF _FULLGAME}
      unit_CalcFogR(pu);
      {$ENDIF}
   end;
end;
begin
   with pu^ do
   with uid^ do
   with player^ do
   if(iscomplete)and(hits>0)then
   begin
      speed:=_speed;
      // ABILITIES
      case _ability of
uab_Teleport      : level:=byte(upgr[upgr_hell_rteleport]>0);
uab_CCFly         : {if(level>0)then
                    begin
                       if(ukfly<>uf_fly)then
                       begin
                          {$IFDEF _FULLGAME}
                          SoundPlayUnit(snd_CCup ,pu,nil);
                          {$ENDIF}
                          ukfly:=uf_fly;
                          zfall:=zfall-fly_hz;
                          if(ua_id<>ua_psability)
                          then unit_OrderClear(pu,false);
                       end;
                       speed:=3;
                    end
                    else
                    begin
                       if(ukfly<>uf_ground)then
                       begin
                          {$IFDEF _FULLGAME}
                          SoundPlayUnit(snd_transport,pu,nil);
                          {$ENDIF}
                          zfall:=fly_hz;
                          ukfly:=uf_ground;
                          unit_OrderClear(pu,false);
                       end;
                       speed:=0;

                       if(ServerSide)and(zfall<>0)then
                         if(CheckCollisionR(x,y+zfall,_r,unum,_ukbuilding,false, upgr[upgr_race_extbuilding[_urace]]=0 )>0)then
                         begin
                            level:=1;
                            buff[ub_CCast]:=fr_fps2;
                         end;
                    end};
      end;

      // DETECTION
      if(_detector)or(buff[ub_HVision]>0)
      then buff[ub_Detect]:=_ub_infinity
      else buff[ub_Detect]:=0;

      // INVIS
      case uidi of
UID_HEye          : buff[ub_Invis]:=b2ib[hits>_hhmhits];
UID_HTotem        : buff[ub_Invis]:=b2ib[upgr[upgr_hell_totminv]>0];
UID_Commando      : buff[ub_Invis]:=b2ib[upgr[upgr_uac_commando]>0];
UID_Demon         : buff[ub_Invis]:=b2ib[upgr[upgr_hell_spectre]>0];
UID_UMine         : buff[ub_Invis]:=_ub_infinity;
      end;

      // OTHER
      case uidi of
UID_UGTurret      : level:=byte(upgr[upgr_uac_plasmt]>0);
UID_Phantom,
UID_LostSoul      : begin
                       tu:=nil;
                       if(IsUnitRange(a_tar,@tu))and(a_reload>0)then buff[ub_CCast]:=fr_fpsd2;
                       if(buff[ub_pain]<=0)then
                         if(buff[ub_CCast]>0)and(tu<>nil)then ukfly:=tu^.ukfly else ukfly:=_ukfly;
                       ukfloater:=not ukfly;
                    end;
UID_UACDron       : begin
                    ukfloater:=upgr[upgr_uac_soaring]>0;
                    {if(map_IsObstacleZone(szone))and(ukfloater)
                    then begin if(speed= _speed)then speed:=_speed div 2;end
                    else begin if(speed<>_speed)then speed:=_speed;      end;  }
                    end;
UID_Demon         : begin
                    ukfloater:=upgr[upgr_hell_ghostm]>0;
                    {if(map_IsObstacleZone(szone))and(ukfloater)
                    then begin if(speed= _speed)then speed:=_speed div 2;{$IFDEF _FULLGAME}if(animw =_animw)then animw:=_animw div 2;{$ENDIF}end
                    else begin if(speed<>_speed)then speed:=_speed;      {$IFDEF _FULLGAME}if(animw<>_animw)then animw:=_animw;      {$ENDIF}end; }
                    end;
UID_UTransport    : begin level:=min2i(upgr[upgr_uac_transport],MaxUnitLevel);transportM:=_transportM+4*level;end;
UID_APC           : begin level:=min2i(upgr[upgr_uac_transport],MaxUnitLevel);transportM:=_transportM+2*level;end;
      end;
      if(upgr[upgr_invuln]>0)then buff[ub_Invuln]:=fr_fps1;
      if(playeri=0)and(g_mode=gm_invasion)then
      begin
         ukfloater:=true;
         if(cycle_order<4 )
         or(cycle_order=11)
         or(cycle_order=21)then buff[ub_HVision]:=_ub_infinity else buff[ub_HVision]:=0;
         if(g_inv_wave_n>3)then
           if(cycle_order<2 )
           or(cycle_order=10)
           or(cycle_order=20)then buff[ub_Invis]:=_ub_infinity else buff[ub_Invis]:=0;
      end;

      // BUILD AREA
      case uidi of
UID_HEye          : isbuildarea:=true;
      else
      if(_isbuilder)then isbuildarea:=not ukfly;
      end;

      // SRANGE
      t:=_srange;
      if(_upgr_srange>0)and(_upgr_srange_step>0)
      then t+=upgr[_upgr_srange]*_upgr_srange_step;
      if(not _ukbuilding)
      then t+=upgr[upgr_race_unit_srange[_urace]]*upgr_race_srange_unit_bonus[_urace];
      SetSRange(t);
   end
   else
   begin
      SetSRange(_srange_min);
      if(hits>0)then
        case uidi of
UID_HEye          :  buff[ub_Invis]:=b2ib[hits>_hhmhits];
        end;
   end;
end;



