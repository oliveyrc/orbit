<?php

declare(strict_types=1);

namespace Drupal\orbit\Plugin\Block;

use Drupal\Core\Block\Attribute\Block;
use Drupal\Core\Block\BlockBase;
use Drupal\Core\Cache\Cache;
use Drupal\Core\StringTranslation\TranslatableMarkup;
use Drupal\node\Entity\Node;

/**
 * Provides a 'Page sections' block.
 */
#[Block(
  id: "page_sections_block",
  admin_label: new TranslatableMarkup("Page sections block"),
  category: new TranslatableMarkup("Orbit"),
)]
class PageSectionsBlock extends BlockBase {

  /**
   * {@inheritdoc}
   */
  public function build() {
    $build = [];
    $node = \Drupal::routeMatch()->getParameter('node');
    $node_revision = \Drupal::routeMatch()->getParameter('node_revision');
    $node_preview = \Drupal::routeMatch()->getParameter('node_preview');

    if (!empty($node_revision)) {
      $node = \Drupal::entityTypeManager()
        ->getStorage('node')
        ->loadRevision($node_revision);
    }
    elseif (!empty($node_preview)) {
      $node = $node_preview;
    }
    elseif (is_string($node)) {
      $node = Node::load($node);
    }

    if ($node && $node->hasField('field_page_sections') && !$node->get('field_page_sections')->isEmpty()) {
      $build['page_sections_block'] = $node->field_page_sections->view(['label' => 'hidden']);
      return $build;
    }

    return [];
  }

  /**
   * {@inheritdoc}
   */
  public function getCacheTags() {
    $node = \Drupal::routeMatch()->getParameter('node');

    if (is_int($node)) {
      $node = Node::load($node);
    }

    if (!empty($node)) {
      return Cache::mergeTags(parent::getCacheTags(), ['node:' . $node->id()]);
    }

    return parent::getCacheTags();
  }

  /**
   * {@inheritdoc}
   */
  public function getCacheContexts() {
    return Cache::mergeContexts(parent::getCacheContexts(), ['route']);
  }

}
