// Production Jetpack Compose Screen Component (Kotlin)
package com.example.app.ui

import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier

@Composable
fun FeedScreen(
    items: List<String>,
    onItemClick: (String) -> Unit,
    modifier: Modifier = Modifier
) {
    LazyColumn(modifier = modifier) {
        items(items, key = { it }) { item ->
            ListItem(
                headlineContent = { Text(item) },
                modifier = Modifier
            )
        }
    }
}
