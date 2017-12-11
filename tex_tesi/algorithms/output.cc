void wrapper::output(Iodatadata, int position)
{
  if(end_of_simulation)
  {
    iodata.flag_A=b_transaction_data[position].data.flag_A;
    iodata.flag_B=b_transaction_data[position+1].data.flag_B;
    iodata.flag_C=b_transaction_data[position+2].data.flag_C;
    iodata.data_D=b_transaction_data[position+3].data.data_D;
  }
}
