package com.example.gitsawe

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.IntrinsicSize
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.CornerRadius
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

@Composable
fun GitsaweCard(
    dateText: String,
    saintTitle: String,
    psalmLines: List<String>,
    modifier: Modifier = Modifier,
    onOverflowClicked: () -> Unit = {}
) {
    val primaryColor = Color(0xFF5A1A1A)
    val mutedLabelColor = Color(0xFF8E8A85)
    val contentTextColor = Color(0xFF1C2421)
    val cardBgColor = Color(0xFFFDFDFD)

    Card(
        modifier = modifier
            .fillMaxWidth()
            .padding(16.dp),
        shape = RoundedCornerShape(24.dp),
        colors = CardDefaults.cardColors(containerColor = cardBgColor),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(20.dp)
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Row(
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    CalendarIcon(color = primaryColor, modifier = Modifier.size(20.dp))
                    Spacer(modifier = Modifier.width(10.dp))
                    Text(
                        text = dateText,
                        color = primaryColor,
                        fontSize = 15.sp,
                        fontWeight = FontWeight.Bold
                    )
                }
                OverflowMenuIcon(color = mutedLabelColor, modifier = Modifier.size(24.dp))
            }

            Spacer(modifier = Modifier.height(12.dp))

            HorizontalDivider(
                modifier = Modifier.fillMaxWidth(),
                thickness = 0.5.dp,
                color = mutedLabelColor.copy(alpha = 0.3f)
            )

            Spacer(modifier = Modifier.height(16.dp))

            Text(
                text = stringResource(id = R.string.label_saint_of_the_day),
                color = mutedLabelColor,
                fontSize = 11.sp,
                fontWeight = FontWeight.SemiBold,
                letterSpacing = 1.sp
            )

            Spacer(modifier = Modifier.height(6.dp))

            Text(
                text = saintTitle,
                color = contentTextColor,
                fontSize = 22.sp,
                fontWeight = FontWeight.Bold,
                fontFamily = FontFamily.Serif
            )

            Spacer(modifier = Modifier.height(24.dp))

            Text(
                text = stringResource(id = R.string.label_mizbak_psalm),
                color = mutedLabelColor,
                fontSize = 11.sp,
                fontWeight = FontWeight.SemiBold,
                letterSpacing = 1.sp
            )

            Spacer(modifier = Modifier.height(12.dp))

            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(IntrinsicSize.Min)
            ) {
                Box(
                    modifier = Modifier
                        .width(3.dp)
                        .fillMaxHeight()
                        .background(color = primaryColor)
                )

                Spacer(modifier = Modifier.width(12.dp))

                Column(
                    verticalArrangement = Arrangement.spacedBy(6.dp)
                ) {
                    psalmLines.forEachIndexed { index, line ->
                        Text(
                            text = line,
                            color = contentTextColor,
                            fontSize = if (index < 2) 16.sp else 14.sp,
                            fontWeight = if (index < 2) FontWeight.SemiBold else FontWeight.Normal,
                            lineHeight = 22.sp
                        )
                        if (index == 1 && psalmLines.size > 2) {
                            Spacer(modifier = Modifier.height(6.dp))
                        }
                    }
                }
            }
        }
    }
}

@Composable
fun CalendarIcon(
    color: Color,
    modifier: Modifier = Modifier
) {
    Canvas(modifier = modifier) {
        val strokeWidth = 2.dp.toPx()
        drawRoundRect(
            color = color,
            topLeft = Offset(0f, size.height * 0.15f),
            size = Size(size.width, size.height * 0.85f),
            cornerRadius = CornerRadius(2.dp.toPx(), 2.dp.toPx()),
            style = Stroke(width = strokeWidth)
        )
        drawLine(
            color = color,
            start = Offset(size.width * 0.25f, 0f),
            end = Offset(size.width * 0.25f, size.height * 0.25f),
            strokeWidth = strokeWidth
        )
        drawLine(
            color = color,
            start = Offset(size.width * 0.75f, 0f),
            end = Offset(size.width * 0.75f, size.height * 0.25f),
            strokeWidth = strokeWidth
        )
        drawLine(
            color = color,
            start = Offset(0f, size.height * 0.45f),
            end = Offset(size.width, size.height * 0.45f),
            strokeWidth = strokeWidth
        )
    }
}

@Composable
fun OverflowMenuIcon(
    color: Color,
    modifier: Modifier = Modifier
) {
    Canvas(modifier = modifier) {
        val radius = 2.dp.toPx()
        val centerY = size.height / 2f
        drawCircle(color = color, radius = radius, center = Offset(size.width * 0.25f, centerY))
        drawCircle(color = color, radius = radius, center = Offset(size.width * 0.5f, centerY))
        drawCircle(color = color, radius = radius, center = Offset(size.width * 0.75f, centerY))
    }
}

@Preview(showBackground = true)
@Composable
fun GitsaweCardPreview() {
    GitsaweCard(
        dateText = stringResource(id = R.string.sample_date),
        saintTitle = stringResource(id = R.string.sample_saint_name),
        psalmLines = listOf(
            stringResource(id = R.string.sample_psalm_line1),
            stringResource(id = R.string.sample_psalm_line2),
            stringResource(id = R.string.sample_psalm_line3),
            stringResource(id = R.string.sample_psalm_line4)
        )
    )
}

@Preview(showBackground = true)
@Composable
fun CalendarIconPreview() {
    CalendarIcon(color = Color(0xFF5A1A1A), modifier = Modifier.size(24.dp))
}

@Preview(showBackground = true)
@Composable
fun OverflowMenuIconPreview() {
    OverflowMenuIcon(color = Color(0xFF8E8A85), modifier = Modifier.size(24.dp))
}
