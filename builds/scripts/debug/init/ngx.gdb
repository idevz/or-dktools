define ddl
    set $log = ngx_cycle->log

    while ($log != 0) && ($log->writer != ngx_log_memory_writer)
        set $log = $log->next
    end

    if ($log->wdata != 0)
    	set $buf = (ngx_log_memory_buf_t *) $log->wdata
    	dump memory debug_log.txt $buf->start $buf->end
    end
end
document ddl
    Dump in memory debug log.
end

define dcfg
    set $cd = ngx_cycle->config_dump
    set $nelts = $cd.nelts
    set $elts = (ngx_conf_dump_t*)($cd.elts)
    while ($nelts-- > 0)
        set $name = $elts[$nelts]->name.data
        printf "Dumping %s to nginx_conf.txt\n", $name
	append memory nginx_conf.txt \
	    $elts[$nelts]->buffer.start $elts[$nelts]->buffer.end
    end
end
document dcfg
    Dump nginx configuration.
end