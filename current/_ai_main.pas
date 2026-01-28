
procedure ai_Builder(pu:PTUnit);
var
build_uid : byte;
build_x,
build_y,
build_dir,
build_step: integer;
rad_dir   : single;
skipEnergyCheck:boolean;

function SetBuildUID(buid:byte):boolean;
var t:cardinal;
begin
   SetBuildUID:=false;
   if(build_uid=0)then
     if(buid in pu^.uid^.uid_prod_Buildings)then
     begin
        t:=CheckUnitReqs(pu^.player,buid);
        if(t=0)or((t=ureq_energy)and(skipEnergyCheck))then
        begin
           SetBuildUID:=true;
           build_uid  :=buid;
        end;
     end;
end;

procedure SetTowers;
begin
   if(build_uid>0)then exit;

   if(ai_need_Towers<=ai_curr_Towers)then exit;


end;
procedure SetGenerators;
begin
   if(build_uid>0)then exit;

   if(map_generators=0)then
     with pu^  do
     with player^ do
       if (ai_energy_future   <ai_need_Energy)
       and(ai_energy_future   <aip_MaxEnergy)
       and(ai_energy_future   <aic_GeneratorsEnergy)
       and(ai_generators_limit<aic_GeneratorsLimit)then
         case race of
         r_hell: SetBuildUID(UID_HSymbol1);
         r_uac : SetBuildUID(UID_UGenerator1);
         end;
end;

procedure SetUnitProds;
var b1,b2:byte;
begin
   if(build_uid>0)then exit;

   with pu^  do
   with player^ do
     if (ai_curr_UnitProds<ai_need_UnitProds)
     and(ai_curr_UnitProds<aip_MaxBarracks)then
     begin
        case race of
        r_hell: begin
                   b1:=UID_HGate;
                   b2:=UID_HBarracks;
                end;
        r_uac : begin
                   b1:=UID_UBarracks;
                   b2:=UID_UFactory;
                end;
        end;
        if(units_uid_e[b2]>=units_uid_e[b1])
        then SetBuildUID(b1)
        else SetBuildUID(b2);

        if(build_uid=0)then
          if(not SetBuildUID(b1))
          then SetBuildUID(b2);
     end;
end;

begin
   build_uid :=0;
   build_x   :=0;
   build_y   :=0;
   build_dir :=-1;
   build_step:=-1;
   skipEnergyCheck:=false;

   with pu^  do
   with player^ do
   begin
      // requirements in this time
      ai_need_Energy:=600+ai_curr_UnitProds*600;
      if(aip_MaxBarracks>0)then
      begin
         ai_need_UnitProds:=(res_energyl_max div 400);
         if(ai_need_UnitProds<1)then ai_need_UnitProds:=1;
         if(ai_need_UnitProds>aip_MaxBarracks)then ai_need_UnitProds:=aip_MaxBarracks;
      end;

      if(aip_MaxForges>0)then
      begin
         ai_need_UpgrProds:=(res_energyl_max div 1000);
         if(ai_need_UpgrProds>aip_MaxForges)then ai_need_UpgrProds:=aip_MaxForges;
      end;

      if(aip_MaxTowers>0)then
      begin

      end;

      // Define UID to build

      if((aip_flags and aif_base_smart_order)>0)then
      begin
         SetTowers;
         SetGenerators;
         SetUnitProds;
      end
      else
        case random(5) of
        0 : SetTowers;
        1 : SetGenerators;
        2 : SetUnitProds;
        end;

      if(build_uid=0)then exit;

      // build

      if(build_dir <0)then build_dir :=random(360);
      if(build_step<0)then build_step:=random(min2i(uid^.uid_r+(aiu_BuildAttempts div 4)*25,srange));

      if(isselected)then writeln(build_uid,' ',build_step,' ',ai_energy_future,' ',ai_need_Energy,' ',aiu_BuildAttempts);

      rad_dir:=build_dir*degtorad;
      build_x:=x+trunc(build_step*cos(rad_dir));
      build_y:=y-trunc(build_step*sin(rad_dir));

      BuildingFindNewPlace(build_x,build_y,build_uid,playeri,@build_x,@build_y);

      if(unit_start_build(build_x,build_y,build_uid,playeri,true)<>ureq_place)
      then aiu_BuildAttempts:=0
      else
        if(aiu_BuildAttempts<aiu_BuildAttempts.MaxValue)then aiu_BuildAttempts+=1;
   end;
end;


procedure ai_Local_Code(pu:PTUnit);
begin
   with pu^  do
     if(ai_alarm_d<NOTSET)then
     begin
        aiu_alarm_d:=ai_alarm_d;
        aiu_alarm_x:=ai_alarm_x;
        aiu_alarm_y:=ai_alarm_y;
     end;
   //if(pu^.isselected)then writeln(ai_inprogress_auid);
end;

procedure ai_Global_Code(pu:PTUnit);
begin
   with pu^     do
   with uid^    do
   with player^ do
   begin
      // units_builders_e
     // units_builders_ec
    { ai_PrimaryType:=0;
     ai_PrimaryID  :=0;  }

     if(uid_isbuilder)then ai_Builder(pu);

   end;
end;


