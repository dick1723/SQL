declare @id nvarchar(40),@ReceiveRecid bigInt
declare @allocated decimal(28,4),@canAllocate decimal(28,4),@Noallocated decimal(28,4)


--select * from rec 
--update allocate set receiveqty=15 where  id='aap02'
update 
	allocate 
set 
	@canAllocate=case 
			when id=@id  then 				 
				@canAllocate 	
		  else 
			receiveQty  
		  end,
	@allocated=case 
			when @canAllocate>0 then 
				case when id=@id then 
					case when isnull(@ReceiveRecid,ReceiveRecid)<=ReceiveRecid then 
						case when @Noallocated>0 then 
							case 
								when @canAllocate<@Noallocated then 
									case when @canAllocate<issueqty then @canAllocate 
											else 
												issueqty 
											end 
								else --@Noallocated 
									case when @Noallocated<issueqty then @Noallocated 
											else 
												issueqty 
											end 
							end
						else 
							case when @canAllocate<issueqty then @canAllocate 
							else 
								issueqty 
							end 
						end
					else 
						0 
					end
				else 
					case 
						when @canAllocate<issueqty then @canAllocate 
					else 
						issueqty 
					end 
				end
		   else 
			0 
		   end,
	@Noallocated=case 
				when allocated>0 then 
					case 
						when @id=id and @Noallocated>0 then @Noallocated-@allocated
					else 
						receiveQty-@allocated 
					end
				else 
					@Noallocated-@allocated
				end,
	@ReceiveRecid=case 
				when @id=id then 
					case when @allocated>0 then 
						case 
							when @Noallocated>0 then ReceiveRecid 
						else 
							ReceiveRecid+1 
						end
					else 
						@ReceiveRecid 
					end
				else 
					case 
						when @Noallocated>0 then ReceiveRecid 
					else 
						ReceiveRecid+1 
				end 
		  end,
 @canAllocate=@canAllocate-@allocated,
 CanAllocated=@canAllocate,
 allocated=@allocated,
 Notallocated=@Noallocated,
 remain=Issueqty-@allocated,
 未配订单=@ReceiveRecid,
 @id=id
 where id='aap02'
 -------------##############  先进先出计算后 ends ##############-------------------
 
--##############显示更新结果##############--
--select IssueRecid,ItemId,inventdimId,issueqty from #t
--where issueqty>0
--order by IssueRecid,ItemId,inventdimId
go
 
----------------##############----------------------
select * from allocate
where issueqty>0 
and id='aap02'
order by Id, TransDate