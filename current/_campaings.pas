

procedure camp_Init;
var x:byte;
begin
   {for x:=0 to LastMission do cmp_mmap[x]:=spr_camp_phobos;

   cmp_mmap[0 ]:=spr_camp_hell;
   cmp_mmap[1 ]:=spr_camp_phobos;
   cmp_mmap[2 ]:=spr_camp_phobos;
   cmp_mmap[3 ]:=spr_camp_deimos;
   cmp_mmap[4 ]:=spr_camp_deimos;
   cmp_mmap[5 ]:=spr_camp_deimos;
   cmp_mmap[6 ]:=spr_camp_mars;
   cmp_mmap[7 ]:=spr_camp_mars;
   cmp_mmap[8 ]:=spr_camp_mars;
   cmp_mmap[9 ]:=spr_camp_earth;
   cmp_mmap[10]:=spr_camp_earth;
   cmp_mmap[11]:=spr_camp_earth;

   cmp_mmap[12]:=spr_camp_phobos;
   cmp_mmap[13]:=spr_camp_phobos;
   cmp_mmap[14]:=spr_camp_phobos;
   cmp_mmap[15]:=spr_camp_deimos;
   cmp_mmap[16]:=spr_camp_deimos;
   cmp_mmap[17]:=spr_camp_deimos;
   cmp_mmap[18]:=spr_camp_hell;
   cmp_mmap[19]:=spr_camp_hell;
   cmp_mmap[20]:=spr_camp_hell;
   cmp_mmap[21]:=spr_camp_mars;
   cmp_mmap[22]:=spr_camp_mars;
   cmp_mmap[23]:=spr_camp_mars;   }
end;
procedure camp_ClearPStarts;
var p:byte;
begin
   for p:=0 to LastPlayer do
   begin
      map_PlayerStartX[p]:=-5000;
      map_PlayerStartY[p]:=-5000;
   end;
end;
procedure camp_SetPStart(p:byte;px,py:integer);
begin
   map_PlayerStartX[p]:=px;
   map_PlayerStartY[p]:=py;
end;
procedure camp_SetPStartMir(p1,p2:byte);
begin
   map_PlayerStartX[p1]:=map_Size1-map_PlayerStartX[p2];
   map_PlayerStartY[p1]:=map_Size1-map_PlayerStartY[p2];
end;
procedure camp_FillPStartsCircle(pstart,pnum:byte;cx,cy,cr,cd:integer);
var p:byte;
dstep,
ddir :integer;
begin
   if(pnum<1)or(pnum>LastPlayer)then exit;

   dstep:=round(360/pnum);
   ddir :=cd;

   for p:=1 to pnum do
   begin
      map_PlayerStartX[pstart]:=cx+round(cr*cos(ddir*DEGTORAD));
      map_PlayerStartY[pstart]:=cy+round(cr*sin(ddir*DEGTORAD));
      ddir  +=dstep;
      pstart+=1;
      if(pstart>LastPlayer)then break;
   end;
end;
procedure camp_SetPlayer(p,r,t:byte);
begin
   with g_PlayersMain[p] do
   begin
      state:=t;
      race :=r;
      if(p=LocalPlayer)then name:=PlayerName;
   end;
end;
procedure camp_CreateUnit(playeri:byte;ux,uy:integer;uuid:byte);
begin
   unit_add(ux,uy,0,uuid,playeri,true,false,0);
end;

procedure cmp_StartMission;
begin
   FillChar(camp_data,SizeOf(camp_data),0);

   g_DefeatedObs:=false;
   case camp_sel of
   0 : case camp_mis_sel of
       0 : begin
              map_scenario  :=mc_ffa8;
              map_generators:=0;
              map_seed      :=666;
              map_Size1     :=4000;
              map_Template  :=mapt_cave;
              map_Symmetry  :=maps_none;
              map_BaseVars;

              LocalPlayer:=0;
              UIPlayer   :=0;

              camp_SetPlayer(LocalPlayer,r_hell,ps_human);
              camp_SetPlayer(4          ,r_uac ,ps_AI   );

              camp_ClearPStarts;
              camp_SetPStart(1,map_Size1 div 4,map_Size1 div 3);
              camp_SetPStartMir(4,1);

              camp_CreateUnit(LocalPlayer,map_PlayerStartX[LocalPlayer],map_PlayerStartY[LocalPlayer],UID_HKeep);

              camp_CreateUnit(4,map_PlayerStartX[4]-150,map_PlayerStartY[4]-150,UID_UCommandCenter);
              camp_CreateUnit(4,map_PlayerStartX[4]+150,map_PlayerStartY[4]+150,UID_UPortal);

              PlayerSetAllowedUnits(LocalPlayer,[ UID_HGate,UID_HSymbol1..UID_HSymbol4,UID_HPools,UID_HFTower,
                                                  UID_Imp,UID_Demon], MaxUnits,true);
           end;
       end;

   end;

   Map_Make;
   ui_Camera_MoveToPoint(map_PlayerStartX[LocalPlayer],map_PlayerStartY[LocalPlayer]);
end;

procedure cmp_MissionCode;
var i:integer;
begin
   case camp_sel of
   0 : case camp_mis_sel of
       0 : begin
              // tutorial stages, subtasks
              with g_PlayersMain[LocalPlayer] do
              begin
                 {if(res_energyl_max<2000)
                 then cmp_data_b1:=1
                 else
                   if(res_energyl_max<2000)}

              end;
              //if(g_PlayersMain[4].units_ucl_e[true,0]=0)then Game_SetStatusWinnerTeam(g_PlayersMain[LocalPlayer].team);
           end;
       end;
   end;
end;

