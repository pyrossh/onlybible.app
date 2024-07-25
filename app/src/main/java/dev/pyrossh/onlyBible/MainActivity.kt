package dev.pyrossh.onlyBible

import android.content.res.Configuration.UI_MODE_NIGHT_MASK
import android.os.Bundle
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.activity.viewModels
import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.lifecycleScope
import kotlinx.coroutines.launch

class MainActivity : AppCompatActivity() {

    private val model by viewModels<AppViewModel>()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        lifecycleScope.launch {
            model.loadData()
        }
        addOnConfigurationChangedListener {
        }
        setContent {
            AppTheme {
                AppHost(model = model)
                if (model.showBottomSheet) {
                    TextSettingsBottomSheet(model = model)
                }
            }
        }
    }

    override fun onSaveInstanceState(outState: Bundle) {
        super.onSaveInstanceState(outState)
        lifecycleScope.launch {
            model.saveData()
        }
    }
}

