// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ABDKMath64x64.sol";

contract RsuReputation {
    uint currentMappingVersion;
    address public owner;
    mapping(address => Reputation[]) public reputations;
    int128 public RepActual;
    mapping(uint => WM) public wms;
    mapping(uint => WVM[]) public wvms;
    mapping(uint => uint) public wvmCount;
    mapping(uint => string) public statusEvent;
    
    constructor() payable {
       owner = msg.sender;
    }

     struct WM {
        uint idMsg;
        address assig;
        uint256 idAlert;
        bool active;
        uint256 timstamp;
    }

    struct WVM {
        address car;
        uint idMsg;
        address assig;
        uint256 idAlert;
        bool ack;
        uint256 timstamp;
    }
    
     struct Reputation {
        address car;
        int128 reputationValue;
    }
    
    function registerWM(uint _idMsg,uint256 _idAlert) public {
        wms[_idMsg] = WM(
            _idMsg,
            msg.sender,
            _idAlert,
            true,
            block.timestamp
        );

    }

   
     function registerWVM(uint _idMsg,uint256 _idAlert, bool _confirmation) public {
        wvms[_idMsg].push(WVM(
            msg.sender,
            _idMsg,
            msg.sender,
            _idAlert,
            _confirmation,
            block.timestamp
        ));
        if(this.totalWVMByIdWM(_idMsg) >= 10){
          int128 ack = this.getAck(_idMsg);
          int128 nack = this.getNack(_idMsg);
          int128 valorVerificador = ABDKMath64x64.div(ack,ABDKMath64x64.add(ack,nack));
         
           setNewReputation(_idMsg,valorVerificador);

        }
    }
    
    function setNewReputation(uint _idMsg, int128 valorVerificador) internal {
        if(valorVerificador > 10149000000000000000) {
              statusEvent[_idMsg] = "TRUE EVENT";
            if(reputations[wms[_idMsg].assig].length > 0){
                
             int128 repActual = reputations[wms[_idMsg].assig][reputations[wms[_idMsg].assig].length-1].reputationValue;
             
             int128 valor1 = ABDKMath64x64.mul(repActual,valorVerificador);
             
             int128 valor2 = ABDKMath64x64.sub(valor1,ABDKMath64x64.mul(ABDKMath64x64.mul(repActual,repActual),valorVerificador));
             
             
             int128 newValue = ABDKMath64x64.add(repActual,valor2);
             
             emit Valor("true event maior que 0.55",newValue);
             
             reputations[wms[_idMsg].assig].push(
                 Reputation(
                     wms[_idMsg].assig,
                     newValue
                 )
              );
            } else {
                
                reputations[wms[_idMsg].assig].push(
                     Reputation(
                     wms[_idMsg].assig,
                     valorVerificador
                 )
                    );
                      emit Valor("true event com reputacao zerada",valorVerificador);
            }
        }
         if(valorVerificador < 8310000000000000000) {
               statusEvent[_idMsg] = "BOGUS EVENT";
              
               if(reputations[wms[_idMsg].assig].length > 0){
                   
                    emit Valor("bogus event precalc",valorVerificador);
                   
                  int128 repActual = reputations[wms[_idMsg].assig][reputations[wms[_idMsg].assig].length-1].reputationValue;
                
                  int128 numerator = ABDKMath64x64.add(repActual,ABDKMath64x64.mul(repActual,valorVerificador));
                
                  int128 newValue = ABDKMath64x64.div(numerator,ABDKMath64x64.fromUInt(2));
                
                  emit Valor("bogus event poscalc com valor",newValue);
                
                  reputations[wms[_idMsg].assig].push(Reputation(wms[_idMsg].assig,newValue));
                
              } else {
                   
                reputations[wms[_idMsg].assig].push(Reputation(wms[_idMsg].assig,valorVerificador));
              }
         }
         
         emit Valor("bogus event poscalc",0);

    }
    
    function getReputationByCar(address _car) external view returns (int128) {
        return reputations[_car][reputations[_car].length-1].reputationValue;
    }
    
    
    function totalWVMByIdWM(uint _idMsg) external view returns (uint256) {
         uint countMsg = 0;
         for (uint i = 0; i < wvms[_idMsg].length; i++) {
             if(wvms[_idMsg][i].idMsg == _idMsg){
                 countMsg++;
             }
         }
        return countMsg;
    }
    
    function getAck(uint _idMsg) external view returns (int128) {
         int128 countAck = 1;
         for (uint i = 0; i < wvms[_idMsg].length; i++) {
             if(wvms[_idMsg][i].ack){
                 countAck++;
             }
         }
        return countAck;
    }
   function getNack(uint _idMsg) external view returns (int128) {
         int128 countNack = 1;
         for (uint i = 0; i < wvms[_idMsg].length; i++) {
             if(!wvms[_idMsg][i].ack){
                 countNack++;
             }
         }
        return countNack;
    }

    event Valor(string who,int128 valor);

}
