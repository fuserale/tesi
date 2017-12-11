void wrapper::isActive_PSL_1(Iodata iodata, int  pos)
{	
  if(iodata.flag_1==1 && first_flag==false)
  {
   table[pos].data.flag_1=iodata.flag_1;
   first_flag==true;
   pos=pos+1;
  }
  if(iodata.data_1!=0 && second_flag==false 
                           && first_flag==true)
  {
   table[pos].data.data_1=iodata.data_1;	
   second_flag==true;
   pos=pos+1;
  }
  if(iodata.data_2!=0 && third_flag==false 
       && first_flag==true && second_flag==true)
  {
   table[pos].data.data_2=iodata.data_2;
   third_flag=true;
   pos=pos-2;
  }
  if(first_flag==true && second_flag==true 
                            && third_flag==true)
  {
   complete_activated_proprety_1=true;
   first_flag_1=second_flag=third_flag=false;
   active++;
   table[pos].activated[active-1]=1;		
  }
}
