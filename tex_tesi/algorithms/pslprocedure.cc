void wrapper::isActive_PSL_1(Iodata iodata, int  pos)
{	
  if(iodata.flag_1==1 && first_flag==false)
  {
   table[pos].data.flag_1=iodata.flag_1;
   first_flag==true;
  }
  if(iodata.data_1!=0 && second_flag==false 
                           && first_flag==true)
  {
   table[pos+1].data.data_1=iodata.data_1;	
   second_flag==true;
  }
  if(iodata.data_2!=0 && third_flag==false 
       && first_flag==true && second_flag==true)
  {
   table[pos+2].data.data_2=iodata.data_2;
   third_flag=true;
  }
  if(first_flag==true && second_flag==true 
                            && third_flag==true)
  {
   complete_activated_proprety_1=true;
   first_flag = false;
   second_flag= false;
   third_flag = false;
   simulation_time+=3;
  }
  else
  {
   partially_activated_proprety_1=true;
   simulation_time+=1;
  }
}
