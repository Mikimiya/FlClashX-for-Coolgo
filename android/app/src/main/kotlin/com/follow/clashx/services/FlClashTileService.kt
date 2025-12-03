package com.follow.clashx.services

import android.os.Build
import android.service.quicksettings.Tile
import android.service.quicksettings.TileService
import androidx.annotation.RequiresApi
import androidx.lifecycle.Observer
import com.follow.clashx.GlobalState
import com.follow.clashx.RunState


@RequiresApi(Build.VERSION_CODES.N)
class FlClashXTileService : TileService() {

    private val observer = Observer<RunState> { runState ->
        updateTile(runState)
    }

    private fun updateTile(runState: RunState) {
        if (qsTile != null) {
            qsTile.state = when (runState) {
                RunState.START -> Tile.STATE_ACTIVE
                RunState.PENDING -> Tile.STATE_UNAVAILABLE
                RunState.STOP -> Tile.STATE_INACTIVE
            }
            qsTile.updateTile()
        }
    }

    override fun onStartListening() {
        super.onStartListening()
        GlobalState.syncStatus()
        GlobalState.runState.value?.let { updateTile(it) }
        GlobalState.runState.observeForever(observer)
    }

    override fun onClick() {
        super.onClick()
        when (qsTile?.state) {
            Tile.STATE_INACTIVE -> {
                GlobalState.handleStart()
            }
            Tile.STATE_ACTIVE -> {
                GlobalState.handleStop()
            }
            else -> {
                GlobalState.handleToggle()
            }
        }
    }

    override fun onTileRemoved() {
        super.onTileRemoved()
    }

    override fun onTileAdded() {
        super.onTileAdded()
    }

    override fun onDestroy() {
        GlobalState.runState.removeObserver(observer)
        super.onDestroy()
    }
}