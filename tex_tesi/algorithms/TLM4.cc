void run()
{
 sc_core::sc_time local_time = qk.get_local_time();
 tlm::tlm_generic_payload trans;
   
 trans.set_data_ptr(reinterpret_cast<unsigned char*>(&data));
 data.rst = true;
   
 trans.set_write();
 initiator_socket->b_transport(trans, local_time);
 update_simulation_time(local_time);
   
 data.rst = false;
 for (int j = 0; j < ni; ++j)
 {
    int v = j % 8;
    data.decipher = sc_dt::sc_logic('0');
    data.indata = sc_dt::sc_lv<64>(plain[v]);
    data.inkey = sc_dt::sc_lv<64>(key[v]);

    trans.set_write();
    initiator_socket->b_transport(trans, local_time);
    update_simulation_time(local_time);

    trans.set_read();
    initiator_socket->b_transport(trans, local_time);
    update_simulation_time(local_time);
 }
}
