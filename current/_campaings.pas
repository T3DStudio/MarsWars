

procedure cmp_Init;
var x:byte;
begin
   for x:=0 to LastMission do cmp_mmap[x]:=spr_c_phobos;

   cmp_mmap[0 ]:=spr_c_hell;
   cmp_mmap[1 ]:=spr_c_phobos;
   cmp_mmap[2 ]:=spr_c_phobos;
   cmp_mmap[3 ]:=spr_c_deimos;
   cmp_mmap[4 ]:=spr_c_deimos;
   cmp_mmap[5 ]:=spr_c_deimos;
   cmp_mmap[6 ]:=spr_c_mars;
   cmp_mmap[7 ]:=spr_c_mars;
   cmp_mmap[8 ]:=spr_c_mars;
   cmp_mmap[9 ]:=spr_c_earth;
   cmp_mmap[10]:=spr_c_earth;
   cmp_mmap[11]:=spr_c_earth;

   cmp_mmap[12]:=spr_c_phobos;
   cmp_mmap[13]:=spr_c_phobos;
   cmp_mmap[14]:=spr_c_phobos;
   cmp_mmap[15]:=spr_c_deimos;
   cmp_mmap[16]:=spr_c_deimos;
   cmp_mmap[17]:=spr_c_deimos;
   cmp_mmap[18]:=spr_c_hell;
   cmp_mmap[19]:=spr_c_hell;
   cmp_mmap[20]:=spr_c_hell;
   cmp_mmap[21]:=spr_c_mars;
   cmp_mmap[22]:=spr_c_mars;
   cmp_mmap[23]:=spr_c_mars;
end;
procedure cmp_ClearPStarts;
var i:byte;
begin
   for i:=0 to LastPlayer do
   begin
      map_PlayerStartX[i]:=-5000;
      map_PlayerStartY[i]:=-5000;
   end;
end;
procedure cmp_SetPStart(p:byte;px,py:integer);
begin
   map_PlayerStartX[p]:=px;
   map_PlayerStartY[p]:=py;
end;
procedure cmp_SetPStartMir(p1,p2:byte);
begin
   map_PlayerStartX[p1]:=map_Size-map_PlayerStartX[p2];
   map_PlayerStartY[p1]:=map_Size-map_PlayerStartY[p2];
end;
procedure cmp_FillPStartsCircle(pstart,pnum:byte;cx,cy,cr,cd:integer);
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
procedure cmp_SetPlayer(p,r,t:byte);
begin
   with g_players[p] do
   begin
      state:=t;
      race :=r;
      if(p=LocalPlayer)then name:=PlayerName;
   end;
end;
procedure cmp_CreateUnit(playeri:byte;ux,uy:integer;uuid:byte);
begin
   unit_add(ux,uy,0,uuid,playeri,true,false,0);
end;

procedure cmp_StartMission;
begin
   cmp_data_b1:= 0;
   cmp_data_b2:= 0;
   cmp_data_b3:= 0;
   cmp_data_c1:= 0;
   g_type:=gt_campaing;

   g_DefeatedObs:=false;
   case cmp_sel of
0  : begin
        map_scenario      :=mc_ffa8;
        map_generators:=0;
        map_seed    :=666;
        map_Size      :=4000;
        map_ObstaclesF     :=4;
        map_Symmetry:=false;
        map_BaseVars;

        LocalPlayer :=0;
        UIPlayer:=0;

        cmp_SetPlayer(LocalPlayer,r_hell,ps_human);
        cmp_SetPlayer(4      ,r_uac ,ps_AI);

        cmp_ClearPStarts;
        cmp_SetPStart(1,map_Size div 4,map_Size div 3);
        cmp_SetPStartMir(4,1);

        cmp_CreateUnit(LocalPlayer,map_PlayerStartX[LocalPlayer],map_PlayerStartY[LocalPlayer],UID_HKeep);

        cmp_CreateUnit(4,map_PlayerStartX[4]-150,map_PlayerStartY[4]-150,UID_UCommandCenter);
        cmp_CreateUnit(4,map_PlayerStartX[4]+150,map_PlayerStartY[4]+150,UID_UPortal);

        PlayerSetAllowedUnits(LocalPlayer,[ UID_HGate,UID_HSymbol1..UID_HSymbol4,UID_HPools,UID_HTower,
                                        UID_Imp,UID_Demon], MaxUnits,true);
     end;
   end;

   Map_premap;
   ui_Camera_MoveToPoint(map_PlayerStartX[LocalPlayer],map_PlayerStartY[LocalPlayer]);
end;

procedure cmp_MissionCode;
var i:integer;
begin
   case cmp_sel of
0  : begin
        // tutorial stages, subtasks
        with g_players[LocalPlayer] do
        begin
           {if(menergy<2000)
           then cmp_data_b1:=1
           else
             if(menergy<2000)}

        end;
        if(g_players[4].ucl_e[true,0]=0)then Game_SetStatusWinnerTeam(g_players[LocalPlayer].team);

     end;
   end;
end;

