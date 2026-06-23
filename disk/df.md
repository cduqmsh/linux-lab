* 전체 용량 구하기

  [ KB 단위 ]
  df -P | grep -v ^Filesystem | awk '{sum += $2} END { print sum " KB" }'

  [ GB 단위 ]
  df -P | grep -v ^Filesystem | awk '{sum += $2} END { print sum/1024/1024 " GB" }'
---------------------------------------------------------------------------------------------------------------------------
* 전체 사용량 구하기

  [ KB 단위 ]
  df -P | grep -v ^Filesystem | awk '{sum += $3} END { print sum " KB" }'

  [ GB 단위 ]
  df -P | grep -v ^Filesystem | awk '{sum += $3} END { print sum/1024/1024 " GB" }'
---------------------------------------------------------------------------------------------------------------------------
* 전체  남은 용량 구하기

  [ KB 단위 ]
  df -P | grep -v ^Filesystem | awk '{sum += $4} END { print sum " KB" }'

  [ GB 단위 ]
  df -P | grep -v ^Filesystem | awk '{sum += $4} END { print sum/1024/1024 " GB" }'
